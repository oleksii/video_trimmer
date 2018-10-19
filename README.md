# video_trimmer
* To launch app:
  * run ```docker-compose up --build``` in the root folder.
* To generate api docs:
  * run ```docker exec -it vtrimapp_trimapp_1 rake docs:generate```.
  * After generating the docs will be available on - http://localhost:3000/docs
* To exec rspec:
  * run ```docker exec -it vtrimapp_trimapp_1 rspec```.
