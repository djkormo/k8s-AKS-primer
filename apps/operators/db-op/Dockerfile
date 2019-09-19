FROM python:3.7
COPY handlers.py /handlers.py
RUN pip install kopf
CMD kopf run --standalone /handlers.py