#!/bin/bash

i=0
for f in $(ls /var/bigbluebutton/published/presentation/)
do
  if [ ! -f /var/bigbluebutton/published/presentation/$f/$f.mp4 ]; then
#     ls -la /var/bigbluebutton/published/presentation/$f/$f.mp4
cat <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  generateName: build-videoi-old-
  namespace: <your namespace name>
  labels:
    meetingId: $f
spec:
  ttlSecondsAfterFinished: 100
  template:
    spec:
      securityContext:
        runAsUser: 998
        runAsGroup: 998
        fsGroup: 998
      volumes:
      - name: bbb-nas
        persistentVolumeClaim:
           claimName: bbb-nas-claim
      - name: cache-volume
        emptyDir: {}
      containers:
      - name: build-video
        resources:
          limits:
            cpu: "1"
            memory: 2Gi
          requests:
            cpu: "1"
            memory: 1Gi
        image: mbcom/kubernetes-bbb-video-download:v2.1
        imagePullPolicy: IfNotPresent
        command: ["node",  "index.js", "-i", "/var/bigbluebutton/published/presentation/$f","-o","/var/bigbluebutton/published/presentation/$f/$f.mp4"]
        volumeMounts:
        - name: bbb-nas
          mountPath: /var/bigbluebutton/published/
        - mountPath: /home/bigbluebutton/tmp
          name: cache-volume
      restartPolicy: Never
  backoffLimit: 2

---

EOF
     i=$((i+1))
  fi
done



exit 0
