GOOS=linux
GOARCH=amd64
TARGET_BUCKET=randomstore.scselvy.com
TARGET_LAMBDA=arn:aws:lambda:us-east-1:950094899988:function:random_store_backend

.ONESHELL:

clean_lambda:
	rm -rf rstore_get/output

clean_app:
	rm -rf RandomStore/dist

clean_node:
	rm -rf RandomStore/node_modules

lambda:
	cd rstore_get;
	GOOS="$(GOOS)" GOARCH="$(GOARCH)" go build -o output/main;
	zip -j output/function.zip output/main;
	cd ..;

app: 
	cd RandomStore;
	npm install;
	npm run build;
	cd ..;

all: app lambda

clean: clean_lambda clean_node clean_app

sync_s3:
	aws s3 rm --recursive "s3://$(TARGET_BUCKET)/assets";
	aws s3 sync RandomStore/dist "s3://$(TARGET_BUCKET)"

sync_lambda:
	aws lambda update-function-code --no-paginate --function-name "$(TARGET_LAMBDA)" --zip-file fileb://rstore_get/output/function.zip 2>&1 1>/dev/null;

sync: sync_s3 sync_lambda