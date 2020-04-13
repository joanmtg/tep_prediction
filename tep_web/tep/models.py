from django.db import models

# Create your models here.
class Paciente(models.Model):
    cedula = models.CharField(unique=True, max_length=10)
    nombres = models.CharField(max_length=30)
    apellidos = models.CharField(max_length=30)    

    def __str__(self):
        return self.nombres + ' ' + self.apellidos

class Diagnostico(models.Model):
    OP_GENERO = (
        ('0','Femenino'),
        ('1','Masculino'),
    )

    OP_FREC_RESPIRATORIA = (
        (0, 'PARO'),
        (1, '15 - 20'),
        (2, '21 - 25'),
        (3, '26 - 30'),
        (4, '31 - 35'),
        (5, '36 - 40'),
        (6, '40 - 45'),
        (7, '46 - 50'),
    )

    OP_S02 = (
        (0, 'PARO'),
        (1, '50 - 60'),
        (2, '70 - 74'),
        (3, '75 - 80'),
        (4, '80 - 84'),
        (5, '85 - 89'),
        (6, '90 - 94'),
        (7, '95 - 100'),
    )

    OP_FREC_CARDIACA = (
        (0, 'PARO'),
        (1, '40 - 50'),
        (2, '60 - 100'),
        (3, '100 - 180'),
    )

    OP_PR_SISTOLICA = (
        (0, 'PARO'),
        (1, '50 - 70'),
        (2, '71 - 90'),
        (3, '91 - 110'),
        (4, '111 - 130'),
        (5, '131 - 150'),
        (6, '151 - 180'),
        (7, '181 - 200'),
    )

    OP_PR_DIASTOLICA = (
        (0, 'PARO'),
        (1, '30 - 40'),
        (2, '41 - 50'),
        (3, '51 - 60'),
        (4, '61 - 70'),
        (5, '71 - 80'),
        (6, '81 - 90'),
        (7, '91 - 100'),
        (7, '101 - 110'),
        (7, '111 - 120'),
    )

    OP_WBC = (
        (1, '3000 - 4000'),
        (2, '4000 - 10000'),
        (3, '10000 - 12000'),
        (4, '12001 - 15000'),
        (5, '15000 - 18000'),
        (6, '18000 - 21000'),
    )

    OP_HB = (
        (1, '7 - 7,99'),
        (2, '8 - 9,99'),
        (3, '10 - 11,49'),
        (4, '11,5 - 15'),
        (5, '15,01 - 16'),
        (6, '16,01 - 17'),
    )

    OP_PLT = (
        (1, '100000 - 149999'),
        (2, '150000 - 500000'),
    )

    OP_SOPLOS = (
        (0, 'NO'),
        (1, 'TRICUSPIDEO'),
        (2, 'AORTICO'),
        (3, 'PULMONAR'),
        (4, 'TRICUSPIDEO Y AORTICO'),
        (5, 'TODOS'),
    )

    OP_DERRAME = (
        (0, 'NO'),
        (1, 'IZQUIERDO'),
        (2, 'DERECHO'),
        (3, 'BILATERAL'),        
    )
    

    genero = models.CharField(max_length=1, choices=OP_GENERO,)
    edad = models.IntegerField()
    bebedor = models.BooleanField()
    fumador = models.BooleanField()
    otra_enfermedad = models.BooleanField()
    procedimiento_15dias = models.BooleanField()
    inmovilidad_inferior = models.BooleanField()
    viaje_prolongado = models.BooleanField()
    antecedentes_tep = models.BooleanField()
    malignidad = models.BooleanField()
    disnea = models.BooleanField()
    dolor_toracico = models.BooleanField()
    tos = models.BooleanField()
    hemoptisis = models.BooleanField()
    disautonomicos = models.BooleanField()
    edema_inferior = models.BooleanField()
    frec_respiratoria = models.IntegerField(choices=OP_FREC_RESPIRATORIA)
    so2 = models.IntegerField(choices=OP_S02)
    frec_cardiaca = models.IntegerField(choices=OP_FREC_CARDIACA)
    pr_sistolica = models.IntegerField(choices=OP_PR_SISTOLICA)
    pr_diastolica = models.IntegerField(choices=OP_PR_DIASTOLICA)
    fiebre = models.BooleanField()
    crepitos = models.BooleanField()
    sibilancias = models.BooleanField()
    soplos = models.IntegerField(choices=OP_SOPLOS)
    wbc = models.IntegerField(choices=OP_WBC)    
    hb = models.IntegerField(choices=OP_HB)
    plt = models.IntegerField(choices=OP_PLT)
    derrame = models.IntegerField(choices=OP_DERRAME)
    
    diagnostico_nn = models.BooleanField(blank=True)
    diagnostico_svm = models.BooleanField(blank=True)
    diagnostico_random_forest = models.BooleanField(blank=True)
    fecha = models.DateTimeField(auto_now_add=True)
    paciente = models.ForeignKey(Paciente, on_delete=models.CASCADE)
