# bbb-video-download for Kubernetes Deployment
A BigBlueButton recording postscript to provide video download capability.

The assembled video includes:
* shared audio and webcams video
* presented slides with
    * whiteboard actions (text and drawings)
    * cursor movements
    * zooming
* screen sharing
* captions


## Install
1. clone the repository on your BBB servers
2. edit `./snippets/post_publish_bbb_video_download.rb.template` and fill in your namespace name everywhere where we writed `bbbvideodownload`  
2.1. create a namespace on your cluster  
2.2. create (if not already done) a persitent volume which has access to your `/var/bigbluebutton/published/` folder (we use an NFS Share)  
2.3. create an PVC as follows  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: bbb-nas-claim
  namespace: <your namespace name>
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: ''
  volumeName: <the name of the volume created in step 2.2>
  volumeMode: Filesystem
```
3. edit `./snippets/kube_config` and fill in your cluster CA crt, and service account tokens for your namespace, we used the kubernetes created default user in namespace
4. install kubectl (https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) on your BBB servers
5. run the following on your BBB server
```bash
# clone repository on server too if you have not done so and enter the repo directory
cp ./snippets/post_publish_bbb_video_download.rb.template /usr/local/bigbluebutton/core/scripts/post_publish/a0_post_publish_bbb_video_download.rb
cp ./snippets/kube_config /usr/local/bigbluebutton/core/scripts/post_publish/
```





## Create downloadable videos for existing recordings
Use `bbb-record --rebuild <presentation_id>` to reprocess a single presentation or `bbb-record --rebuildall` to reprocess all existing presentations. For this the post_publish script must be installed (see installation).

Alternatively you can use the `convert_old.sh` from this repository. Fill in your namespace name and call the script as follows:
```bash
./convert_old.sh > jobs.yaml
```
Be aware the next command will create jobs for all old recordings at once, so you should create a ressource quota for your namespace first to reduce the number of parallel jobs. Kubernetes will then handle the rest for you.  
Example resource quota which will ensure that there will be not more than 8 parallel jobs:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: <your namespace name>
spec:
  hard:
    requests.cpu: "8"
    limits.cpu: "8"
```
Now you can start the converting with the following command:
```bash
kubectl -n <your namespace name> create -f jobs.yaml
```

Alternatively you can run bbb-video-download manually:
```bash
cd /opt/bbb-video-download
sudo -u bigbluebutton docker-compose run --rm --user 998:998 app node index.js -h
>usage: index.js [-h] [-v] -i INPUT -o OUTPUT
>
>A BigBlueButton recording postscript to provide video download capability.
>
>optional arguments:
>  -h, --help            show this help message and exit
>  -v, --version         show program's version number and exit
>  -i INPUT, --input INPUT
>                        path to BigBlueButton published presentation
>  -o OUTPUT, --output OUTPUT
>                        path to outfile
```

Example for a published presentation with internal meeting id 9a9b6536a10b10017f7e849d30a026809852d01f-1597816023148:
```bash
cd /opt/bbb-video-download
kubectl -n <your namespace name> run --rm --user 998:998 app node index.js -i /var/bigbluebutton/published/presentation/9a9b6536a10b10017f7e849d30a026809852d01f-1597816023148 -o /var/bigbluebutton/published/presentation/9a9b6536a10b10017f7e849d30a026809852d01f-1597816023148/9a9b6536a10b10017f7e849d30a026809852d01f-1597816023148.mp4
```

*Please note, that all directories you want to access as input or output must be mounted as volumes in docker-compose.yml. Out of the box only /var/bigbluebutton/published/presentation is mounted.*


## Info for server administrators
MPEG4 is not a free format. You may need to obtain a license to use this script on your server.

## Version history:
- 1.0.0 initial release
- 1.0.1 - 1.0.6 minor bug fixes
- 1.1.0 major rewrite:
- - script is able to render videos with many(!) whiteboard drawings
- - improved overall quality of images & drawings in presentations
- - cursor rendered as in bbb playback
- - removed chapter marks
- 1.1.1 - 1.1.4 minor bug fixes
- 1.2.0 dockerization of the script due to memory management
- 2.0.0 Kubernetes driven video converts instead of conversion directly on BBB server, remove drawings from video, when user has deleted them too
- 2.1.0 BBB v2.3 compatible

## Acknowledgement
Special thanks go to @ichdasich, @deiflou and @christmart for providing enhancements and outstanding support in testing the application.

Main work contributed by @tilmanmoser.
