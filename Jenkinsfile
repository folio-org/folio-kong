import org.jenkinsci.plugins.workflow.libs.Library

@Library('folio_jenkins_shared_libs@EPC') _

buildMvn {
  publishModDescriptor = true
  mvnDeploy = true
  buildNode = 'jenkins-agent-java17'
  runSonarqube = false

  doDocker = {
    buildDocker {
    publishMaster = true
//       healthChk = true
//       healthChkCmd = 'wget --no-verbose --tries=1 --spider http://localhost:8081/admin/health || exit 1'
    }
  }
}