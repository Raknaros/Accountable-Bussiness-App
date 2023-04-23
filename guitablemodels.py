import sys
from PyQt6.QtCore import QAbstractTableModel, Qt, QStringConverter, QModelIndex,QPersistentModelIndex
from PyQt6.QtWidgets import QTableView, QWidget, QMainWindow, QVBoxLayout, QMessageBox, QApplication
from PyQt6.QtSql import QSqlTableModel, QSqlDatabase



class TableEntities(QAbstractTableModel):

    def __init__(self, data):
        super(TableEntities, self).__init__()
        self._data = data
    def data(self, index, role = Qt.ItemDataRole.DisplayRole):
        if index.isValid():
            if role == Qt.ItemDataRole.DisplayRole:
                value = self._data.iloc[index.row(), index.column()]
                if index.column() == 1:
                    return str(int(value))
                return value
    def rowCount(self, index):
        return self._data.shape[0]
    def columnCount(self, index):
        return self._data.shape[1]
    def headerData(self, section, orientation, role):
        # section is the index of the column/row.
        if role == Qt.ItemDataRole.DisplayRole:
            if orientation == Qt.Orientation.Horizontal:
                return str(self._data.columns[section])
            if orientation == Qt.Orientation.Vertical:
                return str(self._data.index[section])

class subdiarioCaja(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Caja")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_1")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioBancos(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Bancos")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_2")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioDiario(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Diario")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_3")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioPlanilla(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Planilla")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_4")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioVentas(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Ventas")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_5")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioInventario(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Inventario")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_6")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()

class subdiarioCompras(QWidget):
    def __init__(self,usu,cla):
        super().__init__()
        self.setWindowTitle("Subdiario Compras")
        self.resize(815, 200)
        self.con = QSqlDatabase.addDatabase("QPSQL")
        self.con.setHostName('impulsadb.cwtkokblelkx.us-west-1.rds.amazonaws.com')
        self.con.setDatabaseName("impulsadb")
        self.con.open(usu,cla)
        # Set up the model
        self.model = QSqlTableModel(self)
        self.model.setTable("_8")
        #self.probar = QStringConverter(self)
        #self.model.
        self.model.setEditStrategy(QSqlTableModel.EditStrategy.OnFieldChange)
        self.model.select()
        # Set up the view
        self.view = QTableView()
        self.view.setModel(self.model)
        self.view.resizeColumnsToContents()
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        self.setLayout(layout)
    def closeEvent(self,event):
        self.con.close()
        #self.con.removeDatabase('qt_sql_default_connection')



#app = QApplication(sys.argv)
#win = subdiarioCaja()
#win.show()
#sys.exit(app.exec())