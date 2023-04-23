import sys
from guitablemodels import *
from sqlprograma import *
from PyQt6.QtCore import QSize, QAbstractTableModel, Qt, pyqtSignal
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton, QDialog, QDialogButtonBox, QGridLayout, QLabel,QLineEdit, QWidget, QMessageBox, QStatusBar, QVBoxLayout, QTableView, QComboBox, QMenu
from PyQt6.QtGui import QPalette, QColor, QAction, QFont, QFontDatabase

app = QApplication(sys.argv)
class Login(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Impulsa OE")
        self.setFixedSize(400,300)
        self.login_dialog()

    def login_dialog(self):
        button = QPushButton("Ingresar",self)
        button.clicked.connect(self.open_login)
        button.setGeometry(160,130,80,50)

    def open_login(self):
        dialogin.exec()

class LoginDialog(QDialog):
    usuario="USER"
    contrasena="PASS"
    def __init__(self, parent=Login):
        super().__init__()
        self.setWindowTitle("¡Bienvenida!")
        self.setFixedSize(QSize(300, 200))
        self.titulo = QLabel("Ingrese sus datos para iniciar", self).move(80,45)
        self.dato1 = QLineEdit(self)
        self.dato1.setPlaceholderText("Usuario")
        self.dato1.move(85,80)
        self.dato2 = QLineEdit(self, echoMode=QLineEdit.EchoMode.Password)
        self.dato2.setPlaceholderText("Contraseña")
        self.dato2.move(85,110)
        self.botonconectar = QPushButton("Conectar", self)
        self.botonconectar.clicked.connect(self.conectar_sql)
        self.botonconectar.move(115,150)

    def conectar_sql(self):
        alerta = QMessageBox(QMessageBox.Icon.Critical,"¡Ups!","Usuario y/o contraseña incorrectos")
        self.usuario = self.dato1.text()
        self.contrasena = self.dato2.text()
        self.dato1.clear()
        self.dato2.clear()
        if app_login(self.usuario,self.contrasena) == "acc":
            self.conta = Acc()
            self.conta.show()
            self.hide()
            window.close()
        elif app_login(self.usuario,self.contrasena) == "fact":
            pass
            self.factu = Acc()
            self.factu.show()
            self.hide()
            window.close()
        elif app_login(self.usuario,self.contrasena) == "prod":
            pass
            self.produ = Acc()
            self.produ.show()
            self.hide()
            window.close()
        else: alerta.exec()

class Acc(QMainWindow):
    estatus = pyqtSignal(str)
    def __init__(self):
        super().__init__()
        self.setFixedSize(700,500)
        self.setWindowTitle("Impulsa OE - Contabilidad")
        menu = self.menuBar()
        file_menu = menu.addMenu("&Archivo")
        view_options = QAction("Opciones",self)
        new_entity = QAction("Nueva Entidad",self)
        new_entity.triggered.connect(self.addentity_dialog)
        salir = QAction("Salir",self)
        salir.triggered.connect(self.close)
        file_menu.addAction(view_options)
        file_menu.addAction(new_entity)
        file_menu.addSeparator()
        file_menu.addAction(salir)
        subdiarios_menu = menu.addMenu("&Subdiarios")
        ver_menu = QAction("Ver",self)
        ver_menu.triggered.connect(self.consult_Ver)
        export_menu = QAction("Exportar",self)
        export_menu.triggered.connect(self.consult_Export)
        import_menu = QAction("Importar",self)
        import_menu.triggered.connect(self.consult_Import)
        subdiarios_menu.addActions([ver_menu,import_menu,export_menu])
        reports_menu = menu.addMenu("&Reportes")
        preliquig = QAction("Preliquidación General",self)
        preliquig.triggered.connect(self.consult_Periodo)
        preliquie = QAction("Preliquidación", self)
        detrac = QAction("Detracciones Pendientes",self)
        reports_menu.addActions([preliquig,preliquie,detrac])
        SUNAT_menu = menu.addMenu("&SUNAT")
        ple = QAction("Generar LE",self)
        ple.triggered.connect(self.consult_PLE)
        pdb = QAction("Generar PDB",self)
        pdb.triggered.connect(self.consult_PLE)
        iqbf = QAction("Generar IQBF",self)
        masivo = QAction("Generar Pago Masivo",self)
        asociador = QAction("Cuadro Asociador",self)
        SUNAT_menu.addActions([ple,pdb,iqbf,masivo,asociador])
        ayuda_menu = menu.addMenu("&Ayuda")
        ayuda_ticket = QAction("Abrir Ticket",self)
        appinfo = QAction("Info",self)
        ayuda_menu.addActions([ayuda_ticket,appinfo])
        self.table = QTableView()
        self.model = TableEntities(tablaEntidades)
        self.table.setModel(self.model)
        self.setCentralWidget(self.table)
        self.setStatusBar(QStatusBar(self))

    def addentity_dialog(self):
        self.addentity = add_entity()
        self.addentity.show()   
    def consult_PLE(self):
        self.entidadperiodo = dialogoPLE(z='ple')
        self.entidadperiodo.show()
    def consult_Export(self):
        self.dialogoParametros = dialogoGeneral(z='ex')
        self.dialogoParametros.show()
    def consult_Ver(self):
        self.dialogosub = dialogoSubdiario(z='ver')
        self.dialogosub.show()
    def consult_Import(self):
        self.dialogosub = dialogoSubdiario(z='im')
        self.dialogosub.show()
    def consult_PDB(self):
        self.entidadperiodo = dialogoPLE(z='pdb')
        self.entidadperiodo.show()
    def consult_Periodo(self):
        self.Periodo=dialogoPeriodo(z='preliquig')
        self.Periodo.show()
#    def import_funct(self,tabla):
#        try:
#            import_data(tabla)
#        except:
#        import_funct.setStatusTip("La importación falló")


class add_entity(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Agregar Entidad")
        self.setFixedSize(QSize(230, 190))
        self.titulo = QLabel("Registre los datos de la entidad", self).move(35,20)
        self.numero_documento = QLineEdit(self)
        self.numero_documento.setPlaceholderText("Numero de documento")
        self.numero_documento.move(48,50)
        self.usuario_sol = QLineEdit(self)
        self.usuario_sol.setPlaceholderText("Usuario SOL")
        self.usuario_sol.move(48,80)
        self.clave_sol = QLineEdit(self)
        self.clave_sol.setPlaceholderText("Clave SOL")
        self.clave_sol.move(48,110)
        self.guardar =QPushButton("Agregar",self)
        #self.guardar.clicked.connect()
        self.guardar.move(75,140)
        self.guardar.clicked.connect(self.nuevaEntidad)
    def nuevaEntidad(self):
        newEntity(ruc=self.numero_documento.text(),usu=self.usuario_sol.text(),cla=self.clave_sol.text(),a=dialogin.usuario,b=dialogin.contrasena)
        self.numero_documento.clear()
        self.usuario_sol.clear()
        self.clave_sol.clear()


class dialogoSubdiario(QDialog):
    def __init__(self,z:str):
        super().__init__()
        self.setWindowTitle("Subdiario")
        self.setFixedSize(QSize(150,100))
        self.titulo = QLabel("Indique el subdiario",self)
        self.titulo.move(25,10)
        self.subdiario = QComboBox(self)
        self.subdiario.move(35,40)
        self.subdiario.addItems(["Caja","Bancos","Diario","Planilla","Ventas","Inventario","Compras"])
        self.generar =QPushButton("Aceptar",self)
        self.generar.move(38,70)
        self.generar.clicked.connect(self.importar if z=='im' else (self.mostrarSubdiario if z=='ver' else None))

    def mostrarSubdiario(self):
        if self.subdiario.currentText()=="Caja":
            self.mostrar=subdiarioCaja(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Bancos":
            self.mostrar=subdiarioBancos(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Diario":
            self.mostrar=subdiarioDiario(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Planilla":
            self.mostrar=subdiarioPlanilla(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Ventas":
            self.mostrar=subdiarioVentas(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Inventario":
            self.mostrar=subdiarioInventario(dialogin.usuario,dialogin.contrasena)
        elif self.subdiario.currentText()=="Compras":
            self.mostrar=subdiarioCompras(dialogin.usuario,dialogin.contrasena) 
        self.mostrar.show()
    def importar(self):
        import_data(tabla=self.subdiario.currentText(),a=dialogin.usuario,b=dialogin.contrasena)

class dialogoPeriodo(QDialog):
    def __init__(self,z:str):
        super().__init__()
        self.setFixedSize(QSize(150,100))
        self.titulo = QLabel("Indique el periodo",self)
        self.titulo.move(25,10)
        self.periodo = QComboBox(self)
        self.periodo.move(35,40)
        self.periodo.addItems(P)
        self.generar =QPushButton("Aceptar",self)
        self.generar.move(38,70)
        self.generar.clicked.connect(self.preliquig)
    def preliquig(self):
        preliquidacion(per=self.periodo.currentText(),a=dialogin.usuario,b=dialogin.contrasena)

class dialogoGeneral(QDialog):
    def __init__(self,z:str):
        super().__init__()
        self.setWindowTitle("Subdiario, entidad y periodo")
        self.setFixedSize(QSize(250,150))
        self.titulo = QLabel("Indique subdiario, entidad y periodo",self)
        self.titulo.move(30,10)
        self.subdiario = QComboBox(self)
        self.subdiario.move(20,40)
        self.subdiario.addItems(L[0])
        self.subdiario.currentIndexChanged.connect(self.updateCombo1)
        self.entidad = QComboBox(self)
        self.entidad.move(20,70)
        self.entidad.setFixedWidth(200)
        self.entidad.addItems(list(L[1])[0])
        self.entidad.currentIndexChanged.connect(self.updateCombo2)
        self.periodo = QComboBox(self)
        self.periodo.addItems(L[2][0][0])
        self.periodo.move(160,40)
        self.generar =QPushButton("Generar",self)
        self.generar.move(80,100)
        self.generar.clicked.connect(self.botonGenerar)
    def updateCombo1(self,value):
        self.entidad.clear()
        self.entidad.addItems(list(L[1])[value])
    def updateCombo2(self,value):
        self.periodo.clear()
        self.periodo.addItems(list(L[2][self.subdiario.currentIndex()])[value])
    def botonGenerar(self):
        #factu.setStatus("Se exportaron"+str(export_data(self.subdiario.currentText(),self.entidad.currentText(),self.periodo.currentText(),dialogin.usuario,dialogin.contrasena))+"registros")
        export_data(self.subdiario.currentText(),self.entidad.currentText(),self.periodo.currentText(),dialogin.usuario,dialogin.contrasena)
        #self.close()

class dialogoPLE(QDialog):
    def __init__(self,z:str):
        super().__init__()
        self.setWindowTitle("Entidad y Periodo")
        self.setFixedSize(QSize(300,100))
        self.titulo = QLabel ("Elija la entidad y el periodo tributario",self).move(50,10)
        self.entidad = QComboBox(self)
        self.entidad.move(30,40)
        self.entidad.setFixedWidth(150)
        self.entidad.addItems([entidad[0] for entidad in comboPLE])
        self.entidad.currentIndexChanged.connect(self.updateComboPLE)
        #self.entidad.setCurrentText(list(entidad[0] for entidad in comboPLE)[0])
        self.periodo = QComboBox(self)
        self.periodo.addItems(list(periodos[1] for periodos in comboPLE)[0])
        self.periodo.move(210,40)
        self.generar =QPushButton("Generar",self)
        self.generar.move(110,70)
        self.generar.clicked.connect(lambda checked: generar_PLE(ent=self.entidad.currentText(),per=self.periodo.currentText(),a=dialogin.usuario,b=dialogin.contrasena) if z=='ple' else None)
    def updateComboPLE(self,value):
        self.periodo.clear()
        self.periodo.addItems(list(periodos[1] for periodos in comboPLE)[value])
    def botonGenerar(self):
        try:
            generar_PLE(ent=self.entidad.currentText(),per=self.periodo.currentText(),a=dialogin.usuario,b=dialogin.contrasena)
        except: pass

window = Login()
dialogin = LoginDialog()



def main():
    window.show()
    sys.exit(app.exec())

if __name__ == '__main__':
    main()

