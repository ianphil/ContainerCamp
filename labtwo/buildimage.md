# Build your own Docker image
We're now going to build a customer docker image using nginx as a base.  
## Review Dockerfile
From your jumpbox, take a look at the Dockerfile:

```
cd ~/ContainerCamp/labtwo
cat Dockerfile
```
You'll see:
```Docker
# Use the nginx docker image as base
FROM nginx

# copy files from the host machine into the image
COPY index.html /usr/share/nginx/html

# inform Docker that the container listens on the specified network port(s) at runtime.
EXPOSE 80
```
Let's explain each of  these sections:

* The `FROM` line says to use the nginx docker image as the base for your custom image.
* The `COPY` line copys a file from the local filesystem into the container filesystem.  In this case, it is copying the local **index.html** file into the **/user/share/nginx.html** directory inside the container.
* The `EXPOSE` line tells docker that the container will be listening on port 80

## Build an image
Now we're going to build our custom image.  Run the following command:
```
 docker build --tag myapp .
 ```
Now we can look at the docker images cached on our machine:
```
docker images
```
You should see an image for nginx (pulled down in the prior lab) and a new image for **myapp**.  Now let's run our new app:
```
docker run -d -p 80:80 --name myapp myapp
docker ps
```
And now you should be able to hit your app from your browser:
> http://[ip address of your jumpbox]

## Optional: Customize your container
Edit the file **index.html** and rebuild your container.
(Be sure to stop and remove the old container first: `docker stop myapp; docker rm myapp`)
