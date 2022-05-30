import java.io.IOException;
import java.sql.*;
import java.util.Scanner;


public abstract class Base {
    protected Scanner scanner;

    public Base() {
        this.scanner = new Scanner(System.in);
    }

    protected abstract String getConnectionString();

    protected abstract void runDemoBody(Connection connection) throws SQLException, IOException;

    public void execute() {
        System.out.println(this.getClass().getSimpleName() + " demo");
        String connectionUrl = this.getConnectionString();

        try {
            // Load SQL Server JDBC driver and establish connection.
            System.out.print("Connecting to SQL Server ... ");
            try (Connection connection = DriverManager.getConnection(connectionUrl)) {
                System.out.println("Done.");

                this.taskA(connection);
                this.readDemo(connection);
                this.taskB(connection);
                this.readDemo(connection);
                this.taskC(connection);
                this.readDemo(connection);
                this.taskD(connection);
                this.readDemo(connection);

                this.runDemoBody(connection);

                System.out.println("All done.");
            }
        } catch (Exception e) {
            System.out.println();
            e.printStackTrace();
        }
    }

    protected void readDemo(Connection connection) throws SQLException, IOException {
        System.out.print("Reading data from table, press ENTER to continue...");
        System.in.read();
        String sql = "SELECT visit_id, user_id, site, clicks_cnt FROM sites_visits;";
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            while (resultSet.next()) {
                System.out.println(
                        resultSet.getInt(1) + " " + resultSet.getString(2) + " " + resultSet.getString(3));
            }
        }
    }
    protected void taskA(Connection connection) throws SQLException {

        System.out.print("Deleting all rows...");
        String sql = new StringBuilder()
                .append("USE Clickstream;")
                .append("DELETE FROM sites_visits;")
                .toString();
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate(sql);
            System.out.println("Done.");
        }
    }

    protected void taskB(Connection connection) throws SQLException {
        System.out.println("Adding rows...");
        String sql = new StringBuilder()
                .append("USE Clickstream;")
                .append("INSERT INTO sites_visits (user_id, site, clicks_cnt) VALUES ")
                .append("(2123, '/home', 12), ")
                .append("(2123, '/orders', 4), ")
                .append("(3094, '/home', 4); ")
                .toString();
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate(sql);
            System.out.println("Done.");
        }
    }

    protected void taskC(Connection connection) throws SQLException {
        System.out.println("Executing taskC...");
        String sql = new StringBuilder()
                .append("USE Clickstream;")
                .append("UPDATE sites_visits SET clicks_cnt = '14' WHERE (user_id = '2123' AND site = '/home'); ")
                .append("UPDATE sites_visits SET clicks_cnt = '6' WHERE (user_id = '2123' AND site = '/orders'); ")
                .append("INSERT INTO sites_visits (user_id, site, clicks_cnt) VALUES ")
                .append("(4362, '/orders', 4); ")
                .toString();
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate(sql);
            System.out.println("Done.");
        }
    }

    protected void taskD(Connection connection) throws SQLException {
        System.out.println("Executing taskD...");
        String sql = new StringBuilder()
                .append("USE Clickstream;")
                .append("DELETE FROM sites_visits")
                .append("WHERE MEAN(visits_cnt) > visits_cnt; ")
                .toString();
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            int counter = 0;
            int x = 0;
            while (resultSet.next()) {
                x = resultSet.getInt(4);
                counter += x;
                System.out.println(
                        x);
            }
            if (x > 19) {
                statement.executeUpdate(sql);
                System.out.println("Done.");
            }
        }
    }
}
