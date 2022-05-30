import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

public class DBexe extends Base {

    public static void main(String[] args) {
        DBexe demo = new DBexe();
        demo.execute();
    }

    @Override
    protected String getConnectionString() {
        return "jdbc:sqlserver://192.168.137.180\\WIN-7KGAL3F2ICE:1433;databaseName=master;user=sa;password=haslo";
    }

    @Override
    protected void runDemoBody(Connection connection) throws SQLException, IOException {
    }

}
