podTemplate(label: 'jenkins-pipeline', containers: [
    containerTemplate(name: 'jnlp', image: 'lachlanevenson/jnlp-slave:3.10-1-alpine', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '200m', resourceLimitCpu: '300m', resourceRequestMemory: '256Mi', resourceLimitMemory: '512Mi'),
    containerTemplate(name: 'docker', image: 'docker:1.12.6', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.11.10', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){
    def image = "gvirtuoso/docker-sample-nginx"
    node ('jenkins-pipeline') {

        checkout scm

        stage('Build') {
            container('docker') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "docker login -u ${env.USERNAME} -p ${env.PASSWORD}"
                }
                sh "docker build -t ${image} ."
                sh "docker push ${image}:latest"
            }
        }

        if (env.BRANCH_NAME =~ "PR-*" ) {
            stage('Deploy') {
                container('kubectl') {
                    // Run routines for PRs
                    sh "echo 'Running deployment routines for PR's'"
                }
            }
        }

        if (env.BRANCH_NAME != 'develop' and env.BRANCH_NAME != 'master') {
            stage('Deploy') {
                container('kubectl') {
                    // Run routines for feature branches
                    sh "echo 'Running deployment routines for feature branches'"
                }
            }
        }

        if (env.BRANCH_NAME == 'develop') {
            stage('Deploy') {
                container('kubectl') {
                    // Here should make de deployment on DEV kubernetes env
                    sh "echo 'Deploying on DEV'"
                }
            }
        }

        if (env.BRANCH_NAME == 'master') {
            stage('Deploy') {
                container('kubectl') {
                    // Here should make de deployment on PROD kubernetes env
                    sh "kubectl apply -f docker-sample-nginx.yaml"
                }
            }
        }

    }
}
