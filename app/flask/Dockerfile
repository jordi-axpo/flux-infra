FROM python:3.10-slim

#Copy the requirements and code into the image
COPY ./requirements.txt /app/requirements.txt
COPY ./src /app/src

#Set working directory
WORKDIR /app

#Install the dependencies and packages in the requirements file
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

CMD ["python", "src/main.py", "--port", "8080"]