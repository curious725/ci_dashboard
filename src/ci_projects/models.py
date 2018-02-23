from django.db import models
from django.core import serializers
from django.db import connection


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

    def __str__(self):
        return "build with session_id {0}, created at {1}".format(
            self.session_id, self.created_at
        )

    @classmethod
    def prepare_data_stacked_bar(cls):

        builds = Build.objects.all().only("created_at", "summary_status").filter(summary_status="passed")
        print(type(builds))
        print(builds)
        data = serializers.serialize("json", builds)
        return data
