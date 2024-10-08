#!bin/bash
VERSION=$(mvn -q \
        -Dexec.executable=echo \
        -Dexec.args='${project.version}' \
        --non-recursive \
        exec:exec)

proxy_repo="93fa-183-87-250-107.ngrok-free.app"
snapshot_repo="f9a0-183-87-250-107.ngrok-free.app"
release_repo="113a-183-87-250-107.ngrok-free.app"


echo $secret_PSW | docker login -u $secret_USR --password-stdin $snapshot_repo
echo "**Pull Base Image From Proxy Repo**"
docker pull $proxy_repo/tomcat:alpine
echo
echo "**Tag the Pulled Image**"
docker tag $proxy_repo/tomcat:alpine tomcat:alpine
echo
docker logout

if [[ $VERSION =~ ^[0-9]+.[0-9]+.[0-9]+-SNAPSHOT ]]
then
    echo "--------------------------"
    echo "* SNAPSHOT REPO SELECTED *"
    echo "--------------------------"
    echo ">> Build Image <<"
    echo "-----------------"
    docker build -t $snapshot_repo/demoapp:$VERSION .
    echo
    echo ">>Login To Docker Registry..."
    echo "-----------------------------"
    echo $secret_PSW | docker login -u $secret_USR --password-stdin $snapshot_repo
    echo
    echo ">> Push Docker Image <<"
    echo "-----------------------"
    docker push $snapshot_repo/demoapp:$VERSION
    echo
    echo ">> Remove Image <<"
    echo "------------------"
    docker rmi $snapshot_repo/demoapp:$VERSION

else
    echo "-------------------------"
    echo "* RELEASE REPO SELECTED *"
    echo "-------------------------"
    echo ">> Build Image <<"
    echo "-----------------"
    docker build -t $release_repo/demoapp:$VERSION .
    echo
    echo ">> Login To Docker Registry <<"
    echo "-------------------------------"
    echo $secret_PSW | docker login -u $secret_USR --password-stdin $release_repo
    echo
    echo ">> Push Docker Image <<"
    echo "-----------------------"
    docker push $release_repo/demoapp:$VERSION
    echo
    echo ">> Remove Image <<"
    echo "------------------"
    docker rmi $release_repo/demoapp:$VERSION
fi

echo
echo ">> Clean UP <<"
echo "--------------"
docker rmi $proxy_repo/tomcat:alpine tomcat:alpine
echo
