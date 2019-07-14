podTemplate(label: 'jenkins-pipeline', containers: [
    containerTemplate(name: 'jnlp', image: 'lachlanevenson/jnlp-slave:3.10-1-alpine', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '200m', resourceLimitCpu: '300m', resourceRequestMemory: '256Mi', resourceLimitMemory: '512Mi'),
    containerTemplate(name: 'docker', image: 'docker:1.12.6', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.11.10', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){
    node ('jenkins-pipeline') {
        checkout scm
        stage('Build & Push') {
            container('docker') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "docker login -u ${env.USERNAME} -p ${env.PASSWORD}"
                }
                sh "docker build -t docker-sample-nginx ."
                if (env.BRANCH_NAME == 'develop') {
                    sh "docker tag docker-sample-nginx:latest gvirtuoso/docker-sample-nginx:develop"
                    sh "docker push gvirtuoso/docker-sample-nginx:develop"
                }
                if (env.BRANCH_NAME == 'master') {
                    sh "docker tag docker-sample-nginx:latest gvirtuoso/docker-sample-nginx:latest"
                    sh "docker push gvirtuoso/docker-sample-nginx:latest"
                }
            }
        }
        stage('Deploy') {
            container('kubectl') {
                script {
                    java.time.LocalDateTime localDateTime = java.time.LocalDateTime.now()
                    java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss")
                    DATETIME = localDateTime.format(formatter)
                }
                if (env.BRANCH_NAME == 'develop') {
                    sh "echo 'Deploying on DEV'"
                }
                if (env.BRANCH_NAME == 'master') {
                    sh "kubectl apply -f docker-sample-nginx.yaml"
                    sh "kubectl patch deployment docker-sample-nginx -p '{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"${DATETIME}\"}}}}}'"
                }
            }
        }
    }
}
