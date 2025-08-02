FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap -a install
COPY . .
EXPOSE 80
CMD ["flask", "run", "--port=80"]
