import org.folio.eureka.EurekaImage
import org.jenkinsci.plugins.workflow.libs.Library

@Library('pipelines-shared-library') _
node('jenkins-agent-java21') {
    stage('Build Docker Image') {
        dir('folio-kong') {
            EurekaImage image = new EurekaImage(this)
            image.setModuleName('folio-kong')
            image.makeImage()
        }
    }
}
