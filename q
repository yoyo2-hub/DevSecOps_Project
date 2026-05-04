[33mcommit 7b8cb85c9f491cb7b709552d43111f5fd40e38dd[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32memna[m[33m)[m
Author: kammoun <oumayma.kammoun@enis.tn>
Date:   Mon Apr 20 14:06:36 2026 +0100

    TSK 2.3 & 2.4: Add K8s manifests and automated deployment

[1mdiff --git a/.github/workflows/k8s-deploy.yml b/.github/workflows/k8s-deploy.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..0caf4a2[m
[1m--- /dev/null[m
[1m+++ b/.github/workflows/k8s-deploy.yml[m
[36m@@ -0,0 +1,46 @@[m
[32m+[m[32mname: K8s Deploy - TSK 2.3 & 2.4[m
[32m+[m
[32m+[m[32mon:[m
[32m+[m[32m  push:[m
[32m+[m[32m    branches:[m
[32m+[m[32m      - dev[m
[32m+[m[32m      - master[m
[32m+[m
[32m+[m[32mjobs:[m
[32m+[m[32m  deploy:[m
[32m+[m[32m    runs-on: ubuntu-latest[m
[32m+[m
[32m+[m[32m    steps:[m
[32m+[m[32m    - name: Checkout code[m
[32m+[m[32m      uses: actions/checkout@v4[m
[32m+[m
[32m+[m[32m    - name: Login to DockerHub[m
[32m+[m[32m      uses: docker/login-action@v3[m
[32m+[m[32m      with:[m
[32m+[m[32m        username: ${{ secrets.DOCKERHUB_USERNAME }}[m
[32m+[m[32m        password: ${{ secrets.DOCKERHUB_TOKEN }}[m
[32m+[m
[32m+[m[32m    - name: Build Docker image[m
[32m+[m[32m      working-directory: backend[m
[32m+[m[32m      run: |[m
[32m+[m[32m        docker build -t kammounab/devsecops-app:latest .[m
[32m+[m[32m        docker push kammounab/devsecops-app:latest[m
[32m+[m
[32m+[m[32m    - name: Setup Minikube[m
[32m+[m[32m      uses: medyagh/setup-minikube@latest[m
[32m+[m[32m      with:[m
[32m+[m[32m        driver: docker[m
[32m+[m
[32m+[m[32m    - name: Configure K8s context[m
[32m+[m[32m      run: kubectl get nodes[m
[32m+[m
[32m+[m[32m    - name: Deploy to Kubernetes[m
[32m+[m[32m      run: |[m
[32m+[m[32m        kubectl apply -f k8s/deployment.yaml[m
[32m+[m[32m        kubectl apply -f k8s/service.yaml[m
[32m+[m
[32m+[m[32m    - name: Verify app running[m
[32m+[m[32m      run: |[m
[32m+[m[32m        kubectl rollout status deployment/devsecops-app --timeout=120s[m
[32m+[m[32m        kubectl get pods[m
[32m+[m[32m        kubectl get services[m
\ No newline at end of file[m
[1mdiff --git a/docker-compose.yml b/docker-compose.yml[m
[1mindex 0b9d8bb..90aa9da 100644[m
[1m--- a/docker-compose.yml[m
[1m+++ b/docker-compose.yml[m
[36m@@ -24,11 +24,9 @@[m [mservices:[m
       DB_USERNAME: postgres[m
       DB_PASSWORD: postgres[m
       # Must be >= 32 bytes for HS256 (jjwt requirement)[m
[31m-      [m
       JWT_EXPIRATION: 86400000[m
[31m-      [m
[31m-      JWT_SECRET: ${JWT_SECRET}[m
[31m-      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}[m
[32m+[m[32m      JWT_SECRET: your-super-secret-key-at-least-32-bytes-long-for-hs256-algorithm[m
[32m+[m[32m      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY:-sk_test_placeholder}[m
     depends_on:[m
       - db[m
 [m
[1mdiff --git a/k8s/deployment.yaml b/k8s/deployment.yaml[m
[1mnew file mode 100644[m
[1mindex 0000000..8e1c706[m
[1m--- /dev/null[m
[1m+++ b/k8s/deployment.yaml[m
[36m@@ -0,0 +1,29 @@[m
[32m+[m[32mapiVersion: apps/v1[m
[32m+[m[32mkind: Deployment[m
[32m+[m[32mmetadata:[m
[32m+[m[32m  name: devsecops-app[m
[32m+[m[32m  labels:[m
[32m+[m[32m    app: devsecops-app[m
[32m+[m[32mspec:[m
[32m+[m[32m  replicas: 2[m
[32m+[m[32m  selector:[m
[32m+[m[32m    matchLabels:[m
[32m+[m[32m      app: devsecops-app[m
[32m+[m[32m  template:[m
[32m+[m[32m    metadata:[m
[32m+[m[32m      labels:[m
[32m+[m[32m        app: devsecops-app[m
[32m+[m[32m    spec:[m
[32m+[m[32m      containers:[m
[32m+[m[32m      - name: devsecops-app[m
[32m+[m[32m        image: TON_USERNAME/devsecops-app:latest[m
[32m+[m[32m        imagePullPolicy: Always[m
[32m+[m[32m        ports:[m
[32m+[m[32m        - containerPort: 8080[m
[32m+[m[32m        resources:[m
[32m+[m[32m          requests:[m
[32m+[m[32m            memory: "256Mi"[m
[32m+[m[32m            cpu: "250m"[m
[32m+[m[32m          limits:[m
[32m+[m[32m            memory: "512Mi"[m
[32m+[m[32m            cpu: "500m"[m
\ No newline at end of file[m
[1mdiff --git a/k8s/service.yaml b/k8s/service.yaml[m
[1mnew file mode 100644[m
[1mindex 0000000..f2e8e82[m
[1m--- /dev/null[m
[1m+++ b/k8s/service.yaml[m
[36m@@ -0,0 +1,13 @@[m
[32m+[m[32mapiVersion: v1[m
[32m+[m[32mkind: Service[m
[32m+[m[32mmetadata:[m
[32m+[m[32m  name: devsecops-service[m
[32m+[m[32mspec:[m
[32m+[m[32m  type: NodePort[m
[32m+[m[32m  selector:[m
[32m+[m[32m    app: devsecops-app[m
[32m+[m[32m  ports:[m
[32m+[m[32m  - protocol: TCP[m
[32m+[m[32m    port: 80[m
[32m+[m[32m    targetPort: 8080[m
[32m+[m[32m    nodePort: 30080[m
\ No newline at end of file[m
