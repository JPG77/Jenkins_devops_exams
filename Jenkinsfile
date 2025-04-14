pipeline {
environment { // Declaration of environment variables
DOCKER_ID = "jpg1" // replace this with your docker-id
DOCKER_IMAGE = "movie"
DOCKER_IMAGE2 = "cast"
PROJET_HOME = "/home/ubuntu/jenkins/Jenkins_devops_exams"

DOCKER_TAG = "v.${BUILD_ID}.0" // we will tag our images with the current build in order to increment the value by 1 with each new build
}
agent any // Jenkins will be able to select all available agents
stages {
        stage(' Docker Build.Movie'){ // docker build MOVIE image stage
            steps {
                script {
                sh '''
                 cd movie-service
                 #docker rm -f TAGmovieNAME
                 docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG .
                sleep 6
                cd ..
                '''
                }
            }
        }
        stage(' Docker Build.Cast'){ // docker build  CAST image stage
            steps {
                script {
                sh '''
                 cd cast-service
                 #docker rm -f TAGCastNAME
                 docker build -t $DOCKER_ID/$DOCKER_IMAGE2:$DOCKER_TAG .
                sleep 6
                cd ..
                '''
                    }
                }    
            }
        stage('Docker run.Movie'){ // run container from our MOVIE builded image
                steps {
                    script {
                    sh '''
                    docker rm Movie
                    docker run -d -p 8001:8000 --name Movie $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    sleep 10
                    docker stop Movie
                    docker rm Movie
                    '''
                    }
                }
            }

        stage('Docker run.Cast'){ // run container from our CAST builded image
                steps {
                    script {
                    sh '''
                    docker rm Cast
                    docker run -d -p 8002:8000 --name Cast $DOCKER_ID/$DOCKER_IMAGE2:$DOCKER_TAG
                    sleep 10
                    docker stop Cast
                    docker rm Cast
                    '''
                    }
                }
            }    

        stage('Test Acceptance'){ // we launch the curl command to validate that the container responds to the request
            steps {
                    script {
                    sh '''
                    curl localhost
                    '''
                    }
                 }

            }
        stage('Docker Push.Movie'){ //we pass the built MOVIE image to our docker hub account
            environment
            {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // we retrieve  docker password from secret text called docker_hub_pass saved on jenkins
            }

            steps {

                script {
                sh '''
                docker login -u $DOCKER_ID -p $DOCKER_PASS
                docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                '''
                    }
                }

            }

        stage('Docker Push.Cast'){ //we pass the built CAST image to our docker hub account
            environment
            {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // we retrieve  docker password from secret text called docker_hub_pass saved on jenkins
            }

            steps {

                script {
                sh '''
                docker login -u $DOCKER_ID -p $DOCKER_PASS
                docker push $DOCKER_ID/$DOCKER_IMAGE2:$DOCKER_TAG
                '''
                    }
                }

            }



stage('Deploiement en dev'){
        environment
        {
        KUBECONFIG = credentials("config") // we retrieve  kubeconfig from secret file called config saved on jenkins
        }
            steps {
                script {
                sh '''
                rm -Rf .kube
                mkdir .kube
                ls
                cat $KUBECONFIG > .kube/config
                cp fastapi/values.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install app fastapi --values=values.yml --namespace dev
                '''
                }
            }

        }
stage('Deploiement en staging'){
        environment
        {
        KUBECONFIG = credentials("config") // we retrieve  kubeconfig from secret file called config saved on jenkins
        }
            steps {
                script {
                sh '''
                rm -Rf .kube
                mkdir .kube
                ls
                cat $KUBECONFIG > .kube/config
                cp fastapi/values.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install app fastapi --values=values.yml --namespace staging
                '''
                }
            }

        }
  stage('Deploiement en prod'){
        environment
        {
        KUBECONFIG = credentials("config") // we retrieve  kubeconfig from secret file called config saved on jenkins
        }
            steps {
            // Create an Approval Button with a timeout of 15minutes.
            // this require a manuel validation in order to deploy on production environment
                    timeout(time: 15, unit: "MINUTES") {
                        input message: 'Do you want to deploy in production ?', ok: 'Yes'
                    }

                script {
                sh '''
                rm -Rf .kube
                mkdir .kube
                ls
                cat $KUBECONFIG > .kube/config
                cp fastapi/values.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install app fastapi --values=values.yml --namespace prod
                '''
                }
            }

        }

}
}

