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
                    #docker rm Movie 2>/dev/null
                    docker run -d -p 8003:8000 --name Movie $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
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
                    #docker rm Cast 2>/dev/null
                    docker run -d -p 8004:8000 --name Cast $DOCKER_ID/$DOCKER_IMAGE2:$DOCKER_TAG
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

                   # docker compose -f docker-compose2.yml up -d 
                   # sleep 5 
                   # curl localhost:8002/api/v1/casts/docs#/
                   # curl localhost:8001/api/v1/movies/docs
                   # docker compose stop 
                                                        
                    
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
                cp fastapi/valuesMovie.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml                
                helm upgrade --install movie fastapi --values=values.yml --namespace dev
                cp fastapi/valuesCast.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install cast fastapi --values=values.yml --namespace dev
                cp fastapi/valuesNginx.yaml values.yml
                helm upgrade --install nginx fastapi --values=values.yml --namespace dev
                cp fastapi/values.bdd.movie.yaml values.yml
                helm upgrade --install bddmovie fastapi --values=values.yml --namespace dev
                cp fastapi/values.bdd.cast.yaml values.yml
                helm upgrade --install bddcast fastapi --values=values.yml --namespace dev



                '''
                }
            }

        }



stage('Deploiement en QA'){
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
                cp fastapi/valuesMovie.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                #/home/ubuntu/jenkins/Jenkins_devops_exams/uninst-dev.sh
                helm upgrade --install movie fastapi --values=values.yml --namespace qa
                cp fastapi/valuesCast.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm list -n dev
                #helm uninstall movie -n dev
                #helm uninstall cast -n dev
                helm upgrade --install cast fastapi --values=values.yml --namespace qa
                cp fastapi/valuesNginx.yaml values.yml
                helm upgrade --install nginx fastapi --values=values.yml --namespace qa
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
                cp fastapi/valuesMovie.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install movie fastapi --values=values.yml --namespace staging
                #/home/ubuntu/jenkins/Jenkins_devops_exams/uninst-dev.sh
                cp fastapi/valuesCast.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                echo "uninst movie"
                helm list -n qua
                #helm uninstall movie -n qua
                #helm uninstall cast -n qua
                helm upgrade --install cast fastapi --values=values.yml --namespace staging
                cp fastapi/valuesNginx.yaml values.yml
                helm upgrade --install nginx fastapi --values=values.yml --namespace staging
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
                cp fastapi/valuesMovie.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm list -n stag
                #helm uninstall movie -n stag
                #helm uninstall cast -n stag
                helm upgrade --install movie fastapi --values=values.yml --namespace prod
                cp fastapi/valuesCast.yaml values.yml
                cat values.yml
                sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                helm upgrade --install cast fastapi --values=values.yml --namespace prod
                cp fastapi/valuesNginx.yaml values.yml
                helm upgrade --install nginx fastapi --values=values.yml --namespace prod
                '''
                }
            }

        }

}
}

