from django.shortcuts import render
from django.http import JsonResponse
from .serializers import BuildSerializer

from .models import Build


def home(request):
    return render(
        request, 'ci_projects/home.html'
    )


def data(request):
    builds = Build.objects.all()
    serializer = BuildSerializer(builds, many=True)
    return JsonResponse(serializer.data, safe=False)
