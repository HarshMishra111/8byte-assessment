1. The first challenge i faced was running the docker container into ec2 instance which is in private subnet. I tried multiple times by enabling the ports and 
editing the inbound rules of security group again and again but it was not resolving as i wanted it to be. I took reference from internet and stackoverflow and got 
stuck in this phase for long time. Later i just created another ec2 and connected it with the ec2 which was in private subnet, and this thing was happening.

2. The second challenge was i was running my pipeline on local machine and not on aws. I first didnt got clicked that how i will run this pipeline on these 
provisioned resources. Later on whole pipeline was running then i got to know that it will be best if i run it on ec2. Managing everything on local and then
migrating it to AWS was not an easy job so i pushed the docker images to docker hub and then built the container inside ec2 so that my application will be
running on aws resources. Overall this was not efficient way but i was having time limitation so this was the way i chose.

3. My project architecture got disturbed too many times due to this above matter. This final architecture is not the best approach but its one of those 
approach which led me to the output i wanted although its temporary fix. I can still do better than this.
