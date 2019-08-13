
cd /tmp/
git clone https://github.com/drone-demos/drone-with-go
cd ./drone-with-go

git remote add gogs http://git.$(minikube ip)/root/drone-go.git
git push -u gogs master
