from django.db import models
from django.core.validators import RegexValidator
from datetime import datetime

numeric = RegexValidator(r'^[0-9]*$', 'Sólo valores numéricos permitidos.')

# Create your models here.
class Paciente(models.Model):
    OP_GENERO = (
        (0,'Femenino'),
        (1,'Masculino'),
    )
    cedula = models.CharField(unique=True, max_length=10, validators=[numeric], verbose_name='cédula')
    nombres = models.CharField(max_length=30)
    apellidos = models.CharField(max_length=30)
    sexo = models.IntegerField(choices=OP_GENERO)
    fecha_nacimiento = models.DateField(verbose_name='Fecha de nacimiento')            

    def __str__(self):
        return self.apellidos + ' ' + self.nombres + ' - ' +self.cedula    
    
    def edad(self):
        return int((datetime.now().date() - self.fecha_nacimiento).days / 365.25)

    @property
    def genero(self):
        return self.sexo,
    
    

class Diagnostico(models.Model):
    OP_GENERO = (
        (0,'Femenino'),
        (1,'Masculino'),
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
        (2, 'AÓRTICO'),
        (3, 'PULMONAR'),
        (4, 'TRICUSPIDEO Y AÓRTICO'),
        (5, 'TODOS'),
    )

    OP_DERRAME = (
        (0, 'NO'),
        (1, 'IZQUIERDO'),
        (2, 'DERECHO'),
        (3, 'BILATERAL'),        
    )    
    
    paciente = models.ForeignKey(Paciente, on_delete=models.CASCADE)
    genero = models.IntegerField(choices=OP_GENERO, verbose_name='Sexo')    
    edad = models.IntegerField()
    bebedor = models.BooleanField()
    fumador = models.BooleanField()
    otra_enfermedad = models.BooleanField()
    procedimiento_15dias = models.BooleanField(verbose_name='Procedimiento Quirúrgico o Traumatismo grave en los últimos 15 días')
    inmovilidad_inferior = models.BooleanField(verbose_name='Inmovilidad en miembro inferior')
    viaje_prolongado = models.BooleanField()
    antecedentes_tep = models.BooleanField(verbose_name='Antecedentes de tromboembolismo pulmonar (TEP/TVP)')
    malignidad = models.BooleanField()
    disnea = models.BooleanField()
    dolor_toracico = models.BooleanField(verbose_name='Dolor torácico')
    tos = models.BooleanField()
    hemoptisis = models.BooleanField()
    disautonomicos = models.BooleanField(verbose_name='Disautonomía')
    edema_inferior = models.BooleanField()
    frec_respiratoria = models.IntegerField(choices=OP_FREC_RESPIRATORIA, verbose_name='Frecuencia respiratoria')
    so2 = models.IntegerField(choices=OP_S02, verbose_name='Saturación de oxígeno en sangre (SO2)')
    frec_cardiaca = models.IntegerField(choices=OP_FREC_CARDIACA, verbose_name='Frecuencia cardiaca')
    pr_sistolica = models.IntegerField(choices=OP_PR_SISTOLICA, verbose_name='Presión sistólica')
    pr_diastolica = models.IntegerField(choices=OP_PR_DIASTOLICA, verbose_name='Presión diastólica')
    fiebre = models.BooleanField()
    crepitos = models.BooleanField(verbose_name='Crepitaciones')
    sibilancias = models.BooleanField()
    soplos = models.IntegerField(choices=OP_SOPLOS)
    wbc = models.IntegerField(choices=OP_WBC, verbose_name='Conteo de glóbulos blancos (WBC)')    
    hb = models.IntegerField(choices=OP_HB, verbose_name='Hemoglobina (HB)')
    plt = models.IntegerField(choices=OP_PLT, verbose_name='Conteo de plaquetas (PLT)')
    derrame = models.IntegerField(choices=OP_DERRAME)
    
    diagnostico_nn = models.BooleanField(blank= True, null=True, verbose_name='Diagnóstico Redes Neuronales')
    diagnostico_svm = models.BooleanField(blank= True, null=True, verbose_name='Diagnóstico SVM')
    diagnostico_random_forest = models.BooleanField(blank= True, null=True, verbose_name='Diagnóstico Random Forest')
    fecha = models.DateTimeField(auto_now_add=True)    
