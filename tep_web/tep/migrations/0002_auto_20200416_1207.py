# Generated by Django 3.0.5 on 2020-04-16 17:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tep', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='diagnostico',
            name='edad',
            field=models.PositiveIntegerField(),
        ),
    ]