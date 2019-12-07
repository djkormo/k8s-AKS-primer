FROM python:3.6.6-alpine
COPY app /app
WORKDIR /app
RUN pip3 install -r requirements.txt && pip3 install --upgrade pip && \
    python3 -m textblob.download_corpora
EXPOSE 5000
ENTRYPOINT ["python3"]
CMD ["sentiment_analysis.py"]
