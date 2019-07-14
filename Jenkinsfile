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
        stage('SCM Checkout') {
            git "https://github.com/${image}.git"
        }
        stage('Build') {
            container('docker') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "docker login -u ${env.USERNAME} -p ${env.PASSWORD}"
                }
                sh "docker build -t ${image} ."
                sh "docker push ${image}:latest"
            }
        }
        stage('Deploy') {
            container('kubectl') {
                sh "kubectl apply -f docker-sample-nginx.yaml"
            }
        }

    }
}
