import csv
from django.contrib.staticfiles.finders import find


def get_data(path=find('session_history.csv')):
    results = {'builds': []}
    with open(path, encoding='utf-8') as file:
        reader = csv.DictReader(file, skipinitialspace=True)
        for row in reader:
            results['builds'].append({
                'session_id': row['session_id'],
                'started_by': row['started_by'],
                'created_at': row['created_at'],
                'summary_status': row['summary_status'],
                'duration': row['duration'],
                'worker_time': row['worker_time'],
                'bundle_time': row['bundle_time'],
                'num_workers': row['num_workers'],
                'branch': row['branch'],
                'commit_id': row['commit_id'],
                'started_tests_count': row['started_tests_count'],
                'passed_tests_count': row['passed_tests_count'],
                'failed_tests_count': row['failed_tests_count'],
                'pending_tests_count': row['pending_tests_count'],
                'skipped_tests_count': row['skipped_tests_count'],
                'error_tests_count': row['error_tests_count']
            })
    return results
