import csv
import time
import pytz
from time import mktime
from datetime import datetime
from django.conf import settings
from django.core.management.base import BaseCommand
from django.contrib.staticfiles.finders import find

from ci_projects.models import Build


def _format_date(date):
    date = time.strptime(date, "%Y-%m-%d %H:%M:%S %Z")
    date = datetime.fromtimestamp(mktime(date))
    date = pytz.timezone(settings.TIME_ZONE).localize(date)
    return date


class Command(BaseCommand):
    help = 'Imports builds from a local CSV file.'

    def add_arguments(self, parser):
        parser.add_argument('file_path', nargs='+', type=str)

    def handle(self, *args, **options):
        file_path = find(options["file_path"][0])

        with open(file_path) as f:
            reader = csv.reader(f)
            next(reader)

            for row in reader:
                _formatted_date = _format_date(row[2])
                Build.objects.get_or_create(
                    session_id=row[0],
                    started_by=row[1],
                    created_at=_formatted_date,
                    summary_status=row[3],
                    duration=row[4],
                    worker_time=row[5],
                    bundle_time=row[6],
                    num_workers=row[7],
                    branch=row[8],
                    commit_id=row[9],
                    started_tests_count=row[10],
                    passed_tests_count=row[11],
                    failed_tests_count=row[12],
                    pending_tests_count=row[13],
                    skipped_tests_count=row[14],
                    error_tests_count=row[15]
                )
