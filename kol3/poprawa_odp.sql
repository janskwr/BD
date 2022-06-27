USE flights_stud

/* ZADANIE 1 */

/* 1.1 */
ALTER TABLE Flights
    ADD FlightsID INT IDENTITY(1,1)

ALTER TABLE Passangers
    ADD PassangersID INT IDENTITY(1,1)

ALTER TABLE Tickets
    ADD TicketsID INT IDENTITY(1,1)

ALTER TABLE Flights
    ADD CONSTRAINT PK_Flights
    PRIMARY KEY(FlightsID)

ALTER TABLE Passangers
    ADD CONSTRAINT PK_Passangers
    PRIMARY KEY(PassangersID)

ALTER TABLE Tickets
    ADD CONSTRAINT PK_Tickets
    PRIMARY KEY(TicketsID)


/* 1.2 */

ALTER TABLE Tickets
    ALTER COLUMN passanger INT

ALTER TABLE Tickets
    ADD CONSTRAINT FK_Tickets_passanger
    FOREIGN KEY(passanger)
    REFERENCES Passangers(PassangersID)

ALTER TABLE Tickets
    ALTER COLUMN flight INT

ALTER TABLE Tickets
    ADD CONSTRAINT FK_Tickets_flight
    FOREIGN KEY(flight)
    REFERENCES Flights(FlightsID)


/* 1.3 */

ALTER TABLE Tickets
ADD cost MONEY

/* 1.4 */

ALTER TABLE Flights
    ALTER COLUMN destination CHAR(50)


/* ZADANIE 2 */

IF OBJECT_ID('procedura') IS NOT NULL
	DROP PROC procedura;
GO

CREATE PROCEDURE procedura
    @origin VARCHAR(50),
    @destination VARCHAR(50),
    @PassangersID INT
AS
BEGIN

    IF(SELECT COUNT(*) FROM Flights WHERE Flights.origin = @origin AND Flights.destination = @destination) = 0
    BEGIN
        print 'There are no flights with given parameters. Proposing alternative destinations.....';
        SELECT TOP 5 * FROM Flights WHERE Flights.origin = @origin;
        RETURN;
    END;

    print 'Booking flight...';

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    BEGIN TRANSACTION
    BEGIN TRY

        IF(SELECT COUNT(*) FROM Flights WHERE Flights.origin = @origin AND Flights.destination = @destination)
            BEGIN
                ROLLBACK TRANSACTION
            END

        UPDATE Tickets
            SET passanger = @PassangersID
            WHERE Tickets.TicketsID = (SELECT MAX(Tickets.TicketsID) FROM Tickets JOIN Flights F on F.FlightsID = Tickets.flight)
        print 'Welcome on board.'

    COMMIT TRANSACTION
    END TRY

    BEGIN CATCH
        print 'Something went wrong'
        ROLLBACK TRANSACTION
    END CATCH
END



/* ZADANIE 3 */

/* 3.1 */
/* bo robimy na foreign keys w celu łatwiejszego łączenia */
CREATE NONCLUSTERED INDEX IX_passanger ON dbo.Tickets(passanger)
CREATE NONCLUSTERED INDEX IX_flight ON dbo.Tickets(flight)

/* 3.2 */
/* indeksy na origin lub destination, raczej unique */
CREATE UNIQUE NONCLUSTERED INDEX IX_origin ON dbo.Flights(origin)
/* lub */
CREATE UNIQUE NONCLUSTERED INDEX IX_destination ON dbo.Flights(destination)


/* 3.3 */
/* indeks stworzony z dwóch kolumn, suername i name, w celu łatwiejszego uzytkowania sortujemy alfabetycznie */
CREATE NONCLUSTERED INDEX IX_surname_name ON dbo.Passangers(surname ASC, name ASC)


/* 3.4 */
/* indeks na passanger bo to ich właśnie musimy pogrupować */
CREATE NONCLUSTERED INDEX IX_passanger ON dbo.Tickets(passanger)

/* 3.5 */
/* najpierw passanger, flight bo najpierw sprawdzam niekupione a potem grupuje po locie */
CREATE NONCLUSTERED INDEX IX_passanger_flight ON dbo.Tickets(passanger, flight)

/* 3.6 */
/* index na flight, passanger bo najpierw wybieram lot a potem sprawdzam gdzie null w passagnerze */
CREATE NONCLUSTERED INDEX IX_flight_passanger ON dbo.Tickets(flight, passanger)

