# static-website-example

we gonna create a Gitlab CI/CD pipeline to deploy  a static website in a staging environment and a production environment.

Here is the project gileb repo link [static-website-example](https://gitlab.com/zinima/static-website-example) .

prerequisites:

 1. Install gitlab software or use the hosted version on gitlab.com (you have to create a gitlab account).
 2. Install a Gitlab Runner application or use the shared runners provided by gitlab.
     Here we're using a shared gitlab runner with Docker-in-Docker configuration (dind).
 3. Clone the static-website-example repo: `git clone https://github.com/diranetafen/static-website-example.git`
 4. Create  a gitlab repo called  static-website-example
 5. push the cloned folder static-website-example to the gitlab repo.

## Dockerfile and nginx configuration

### nginx configuration

we gonna use Heroku to deploy the website.

Heroku assigns a random port for the web application.

So we can use Heroku , we have to configure nginx to variabilize the port.

1.Create a nginx.conf file in the gitleb repo (static-website-example):

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git24.PNG)

The **PORT** variable within the listen directive refers to the listening port of the server for our application .

In the location bloc , we specify the directory containing the website files within the root directive .

### Dockerfile

Create a Dockerfile in the same gitlab repo:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git25.PNG)

Dockerfile instructions:
 1. you start from the base image nginx:1.23.2-alpine
 2. you specify the maintainer.name=your_name  and maintainer.email=your_email
 3. Run an update and remove all files from /usr/share/nginx/html/
 4. Copy the previous nginx.conf file to /etc/nginx/conf.d/default.conf
     file which is the nginx default configuration 
  5.Add the website files to /usr/share/nginx/html/ directory
  6.Run  nginx in the foreground and change the PORT variable with the given value at the start of the container :`CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'`
  
## GitLab CI/CD

### Intro

CI/CD pipeline is based on jobs defined in .gitlab-ci.yml file and executed by runners . 

Every job must contain at least :

 1.A base image and some services
 2.stage section to define the working stage
 3.script section to list instructions

Create a .gitlab-ci.yml file in the gitlab repo.

 1. Define the image and services used to run the jobs globally at the beginning of the .gitlab-ci.yml .
 2. List the stages of the pipeline 
 
![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git26.PNG) 
  

### Build job

This job will build the Dockerfile and generate an artifact which is an archive static-website.tar.

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git27.PNG)

job instructions:

 1. Specify the stage (build)
 2. List the build instructions within the **script** section
 3. Define the produced artifact within the **artifacts** section
 
 Once you commit these changes , a pipeline will start.
 
- Go to CI/CD>pipelines , you should see this result:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git28.PNG)


###  Test job

This job will test the produced artifact.

 1. You have to load the image: `docker load < static-website.tar`
 2. Run a container and assign the value 8080 to the environment variable **PORT** (it refers to the listening port of nginx server): `docker run --name website -d -p 80:8080 -e PORT=8080 static-website`
 3. Wait 5 seconds to be sure that the container started :`sleep 5`
 4. Install curl : `apk add --no-cache curl`
 5. Get the website content and test if it contains the word Dimension:`curl "http://docker" | grep -q "Dimension"`
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git29.PNG)
 
 6. Commit these changes in .gitlab-ci.yml 
 7. Go to CI/CD>pipelines , you should see this result:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git30.PNG)
 
 
### Release job

This job will release the produced image with a name and a significant tag and store it in gitlab container registry.

 1. Create an env variable called STATIC_IMAGE_NAME
     go to settings>CI/CD , expand the variables section and click on **add variable** :
      ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git31.PNG)
      
      following the image , you specify a variable key **STATIC_IMAGE_NAME**
      and a variable value **registry.gitlab.com/your_username/your_working_gitlab_repo**
      
 2. Load the image : `docker load < static-website.tar`
 3. Rename and tag the image using the predefined env variable CI_COMMI_SHORT_SHA refering to short commit hash code : `docker tag static-website "${STATIC_IMAGE_NAME}:${CI_COMMIT_SHORT_SHA}"`
 4. Rename and tag the image using the predefined env variable CI_COMMI_REF_NAME refering the brabch on which we commit : `docker tag static-website "${STATIC_IMAGE_NAME}:${CI_COMMIT_REF_NAME}"`
 5. login to gitlab container registry : `docker login -u "${CI_REGISTRY_USER}" -p "${CI_REGISTRY_PASSWORD}" "${CI_REGISTRY}"`
 6. push the 2 images : `docker push "${STATIC_IMAGE_NAME}:${CI_COMMIT_SHORT_SHA}"`
`docker push "${STATIC_IMAGE_NAME}:${CI_COMMIT_REF_NAME}"`

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git32.PNG)

 7. Commit these changes 
 8.  Go to CI/CD>pipelines , you should see this result:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git33.PNG)
 
### Deployment

We gonna deploy the website to 2 env staging and production using Heroku .

 1. Create a heroku account.
 2. Go to your heroku account settings and copy the API key 
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git34.PNG)
  
 3. Create an env variable called HEROKU_API_KEY
     go to settings>CI/CD , expand the variables section and click on **add variable** :
     ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git35.PNG)
     
      following the image , you specify a variable key **HEROKU_API_KEY**
      and a variable value **your_heroku_api_key** which is the copied API key in step 2 .
 4. Define these global variables at the beginning of .gitlab-ci.yml:
 5. ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git36.PNG) 

#### Staging job

This job will deploy  the website in a staging environment .
In .gitlab-ci.yml :

 1. Specify the environment name and url                    
 2. Specify that this job shoud run only on master branch: `- master`
 3. install heroku CLI: `npm install -g heroku`
 4. login to heroku container registry : `heroku container:login`
 5. create a heroku application named static-website-staging: `heroku create static-website-staging || echo "application already exists"`                
  if you encounter a problem with the application name try to change it . 
 6. push the image to heroku container registry as web image(at this step heroku will rebuild the pushed image) : `heroku container:push -a static-website-staging web`
 7. release the image and run the container :`heroku container:release -a static-website-staging web`
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git37.PNG) 
 
 8. Commit these changes
 9. Go to CI/CD>pipelines, you should see this result:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git38.PNG) 

#### Production job

This job will deploy  the website in a production environment .

In .gitlab-ci.yml add the same instructions as in staging job with  slight changes:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git39.PNG)

- Commit thes changes.
- Go to CI/CD>pipelines , you should have this result:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git40.PNG)

#### Validate staging and production env

To validate both staging and production env , we gonna run 2 tests **validate-staging** and **validate-production** based on a job template :

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git41.PNG)

In these tests you simply:

 1. Install curl
 2. Get the website content and check if it contains the word **Dimension**
 3. Commit these changes
 4. Go to CI/CD>pipelines, you'll have tis result:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git42.PNG)

### Merge changes to master branch

At this step , we gonna edit the website code and merge the changes to master branch.

#### Review job

This job deploy the website with added changes to a dynamic environment.

In .gitlab-ci.yml add the same instructions as in staging job with  slight changes:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git43.PNG)

⚠️In environment section , we add the instruction on_stop to define the name of the job that gonna stop and delete the dynamic env.

⚠️with the instruction only , we specify that this job should run only in case of merge requests.

#### Stop review job

This job delete the dynamic env .

In .gitlab-ci.yml add the same instructions as in staging job with  slight changes:

 1. Specify that this job runs only in case of merge requests :`- merge_requests`
 2. Mention that this job runs manually so you can test the website in dynamic env and stop it manually : `when: manual`
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git44.PNG)
 
 3. Commit the changes to master branch .
 4. Go to CI/CD>pipelines , and stop the launched pipeline o master branch because it's triggered by adding review-job and stop-review-job.
 
#### Feature branch

 1. Add a branch named **feature** to the gitlab repo
  ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git45.PNG)
  
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git46.PNG)


![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git47.PNG)

 2. Go to feature branch
 3. Go to static-website-example>index.html
 4. Add these changes and commit:
  ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git48.PNG)


![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git49.PNG)


 5. This message will appear , click on create merge request:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git50.PNG)

 6. Fill in this form and click on create merge request:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git51.PNG)
 
 
![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git52.PNG)

 7.Go to CI/CD>pipelines , you should see 2  launched pipelines  :
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git53.PNG)

This means that the new version of the website is deployed to a dynamic env.

 8. Go to your heroku account dashboard, you should see a new added app:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git54.PNG)
 
 
 9. Open the app, you'll have this result:
 
![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git55.PNG)
 
In the above image , we see that a new item **TEST** is successfully added to the menu list.

 10. Go to Merge requests>click on the  existing open merge request>click on Merge:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git56.PNG)
 
        This way the changes will be merged to master branch and feature branch will be deleted.
        
 11. Go to CI/CD>pipelines and start start manually the stop-review-job by clicking on run icon on right side:
  ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git53.PNG)
  
     This will delete the dynamic env.
     
 12.Go to CI/CD>pipelines, you sould have this result:
 ![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git57.PNG) 
 
13.Go to your gitlab repo , you should have one branch master:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git58.PNG)

14.Go to Deployment>Environments, you should have 2 available env and one stopped env:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git59.PNG)


![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git60.PNG)

In your heroku account dashboard , you should have 2 deployed applications:

![private](https://github.com/ImaneKABKAB/formation-eazytraining-devops-gitlabCICD/blob/master/images/git61.PNG)


15.Open the 2 apps , they should look like this [static-website-production.herokuapp.com](https://static-website-production.herokuapp.com/) and [static-website-staging.herokuapp.com](https://static-website-staging.herokuapp.com/)

