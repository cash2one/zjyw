# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('oa', '0003_myuser'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='myuser',
            name='user',
        ),
        migrations.DeleteModel(
            name='MyUser',
        ),
    ]
