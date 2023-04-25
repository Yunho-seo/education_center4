# Generated by Django 4.2 on 2023-04-25 06:25

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Addr_Info",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=20, verbose_name="이름")),
                ("age", models.IntegerField(verbose_name="나이")),
                ("addr", models.TextField(verbose_name="주소")),
            ],
            options={
                "verbose_name": "개인주소",
                "verbose_name_plural": "주소록",
                "ordering": ["name"],
            },
        ),
    ]