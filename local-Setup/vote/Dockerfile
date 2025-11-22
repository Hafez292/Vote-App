FROM python:3.12-slim

RUN useradd -m vote
USER vote

WORKDIR /vote
COPY . /vote/
EXPOSE 8080
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "app.py"]
