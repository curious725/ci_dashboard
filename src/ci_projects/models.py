from django.db import models


class Build(models.Model):
    session_id = models.IntegerField(primary_key=True)
    started_by = models.EmailField()
    created_at = models.DateTimeField()
    summary_status = models.CharField(max_length=100)
    duration = models.FloatField()
    worker_time = models.FloatField()
    bundle_time = models.FloatField()
    num_workers = models.IntegerField()
    branch = models.CharField(max_length=100)
    commit_id = models.CharField(max_length=255)
    started_tests_count = models.IntegerField()
    passed_tests_count = models.IntegerField()
    failed_tests_count = models.IntegerField()
    pending_tests_count = models.IntegerField()
    skipped_tests_count = models.IntegerField()
    error_tests_count = models.IntegerField()
