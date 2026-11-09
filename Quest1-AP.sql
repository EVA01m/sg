--Справочные таблицы--

CREATE TABLE dbo.Departments (
    DepartmentId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Login NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(200) NOT NULL UNIQUE,
    Role NVARCHAR(30) NOT NULL
        CHECK (Role IN (N'ADMIN', N'TECHNOLOGIST', N'OPERATOR', N'LAB_WORKER')),
    DepartmentId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Departments(DepartmentId),
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    ProductType NVARCHAR(100) NOT NULL,
    ReleaseForm NVARCHAR(100) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'DRAFT'
        CHECK (Status IN (N'DRAFT', N'ACTIVE', N'ARCHIVED')),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Materials (
    MaterialId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    MaterialType NVARCHAR(100) NOT NULL,
    UnitOfMeasure NVARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.MaterialBatches (
    MaterialBatchId INT IDENTITY(1,1) PRIMARY KEY,
    MaterialId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Materials(MaterialId),
    BatchNumber NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(14,4) NOT NULL
        CHECK (Quantity > 0),
    ReceivedAt DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,

    CONSTRAINT UQ_MaterialBatch UNIQUE (MaterialId, BatchNumber),
    CONSTRAINT CK_MaterialBatch_Dates CHECK (ExpiryDate > ReceivedAt)
);

CREATE TABLE dbo.Equipment (
    EquipmentId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    EquipmentType NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200) NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

--Таблицы рецептур--


CREATE TABLE dbo.Recipes (
    RecipeId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Products(ProductId),
    Version INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT N'DRAFT'
        CHECK (Status IN (N'DRAFT', N'APPROVED_ACTIVE', N'ARCHIVED')),
    CreatedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ApprovedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ApprovedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_Recipe_Product_Version UNIQUE (ProductId, Version)
);

CREATE TABLE dbo.RecipeComponents (
    RecipeComponentId INT IDENTITY(1,1) PRIMARY KEY,
    RecipeId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Recipes(RecipeId)
        ON DELETE CASCADE,
    MaterialId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Materials(MaterialId),
    Percentage DECIMAL(7,4) NOT NULL
        CHECK (Percentage > 0 AND Percentage <= 100),

    CONSTRAINT UQ_RecipeComponent UNIQUE (RecipeId, MaterialId)
);

CREATE TABLE dbo.TechCards (
    TechCardId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Products(ProductId),
    Version INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT N'DRAFT'
        CHECK (Status IN (N'DRAFT', N'APPROVED_ACTIVE', N'ARCHIVED')),
    CreatedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ApprovedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ApprovedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_TechCard_Product_Version UNIQUE (ProductId, Version)
);

CREATE TABLE dbo.TechCardSteps (
    TechCardStepId INT IDENTITY(1,1) PRIMARY KEY,
    TechCardId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.TechCards(TechCardId)
        ON DELETE CASCADE,
    StepNumber INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    StandardDurationMinutes INT NULL
        CHECK (StandardDurationMinutes > 0),

    CONSTRAINT UQ_TechCardStep UNIQUE (TechCardId, StepNumber)
);

CREATE TABLE dbo.StepParameters (
    ParameterId INT IDENTITY(1,1) PRIMARY KEY,
    TechCardStepId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.TechCardSteps(TechCardStepId)
        ON DELETE CASCADE,
    ParameterName NVARCHAR(150) NOT NULL,
    TargetValue DECIMAL(14,4) NULL,
    MinValue DECIMAL(14,4) NULL,
    MaxValue DECIMAL(14,4) NULL,
    UnitOfMeasure NVARCHAR(30) NULL,

    CONSTRAINT UQ_StepParameter UNIQUE (TechCardStepId, ParameterName)
);

--Заказы партий--

CREATE TABLE dbo.ProductionOrders (
    ProductionOrderId INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    ProductId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Products(ProductId),
    RecipeId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Recipes(RecipeId),
    TechCardId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.TechCards(TechCardId),
    PlannedQuantity DECIMAL(14,4) NOT NULL
        CHECK (PlannedQuantity > 0),
    Status NVARCHAR(20) NOT NULL DEFAULT N'CREATED'
        CHECK (Status IN (N'CREATED', N'IN_PROGRESS', N'COMPLETED', N'CANCELLED')),
    CreatedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.ProductionBatches (
    ProductionBatchId INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    ProductionOrderId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionOrders(ProductionOrderId),
    ProductId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Products(ProductId),
    RecipeId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Recipes(RecipeId),
    TechCardId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.TechCards(TechCardId),
    Status NVARCHAR(20) NOT NULL DEFAULT N'CREATED'
        CHECK (Status IN (
            N'CREATED', N'IN_PROGRESS', N'QC',
            N'APPROVED', N'REJECTED', N'CANCELLED'
        )),
    StartedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    StartedAt DATETIME2 NULL,
    CompletedAt DATETIME2 NULL,
    FinalQualityDecision NVARCHAR(20) NULL
        CHECK (FinalQualityDecision IN (N'APPROVED', N'REJECTED', N'PENDING')),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_Batch_Dates CHECK (
        CompletedAt IS NULL OR StartedAt IS NULL OR CompletedAt >= StartedAt
    )
);

CREATE TABLE dbo.BatchMaterialUsage (
    UsageId INT IDENTITY(1,1) PRIMARY KEY,
    ProductionBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionBatches(ProductionBatchId),
    MaterialBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.MaterialBatches(MaterialBatchId),
    QuantityUsed DECIMAL(14,4) NOT NULL
        CHECK (QuantityUsed > 0),
    UsedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    UsedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_BatchMaterialUsage UNIQUE (ProductionBatchId, MaterialBatchId)
);

CREATE TABLE dbo.BatchStepExecutions (
    ExecutionId INT IDENTITY(1,1) PRIMARY KEY,
    ProductionBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionBatches(ProductionBatchId),
    TechCardStepId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.TechCardSteps(TechCardStepId),
    Status NVARCHAR(20) NOT NULL DEFAULT N'PENDING'
        CHECK (Status IN (N'PENDING', N'IN_PROGRESS', N'COMPLETED', N'FAILED')),
    StartedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    StartedAt DATETIME2 NULL,
    CompletedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    CompletedAt DATETIME2 NULL,
    Notes NVARCHAR(MAX) NULL,

    CONSTRAINT UQ_BatchStepExecution UNIQUE (ProductionBatchId, TechCardStepId),
    CONSTRAINT CK_Execution_Dates CHECK (
        (StartedAt IS NULL AND CompletedAt IS NULL)
        OR (StartedAt IS NOT NULL AND CompletedAt IS NULL)
        OR (StartedAt IS NOT NULL AND CompletedAt IS NOT NULL AND CompletedAt >= StartedAt)
    )
);

CREATE TABLE dbo.ExecutionParameterValues (
    ValueId INT IDENTITY(1,1) PRIMARY KEY,
    ExecutionId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.BatchStepExecutions(ExecutionId)
        ON DELETE CASCADE,
    ParameterId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.StepParameters(ParameterId),
    MeasuredValue DECIMAL(14,4) NULL,
    RecordedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_ExecutionParameterValue UNIQUE (ExecutionId, ParameterId)
);

CREATE TABLE dbo.EquipmentTelemetry (
    TelemetryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductionBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionBatches(ProductionBatchId),
    EquipmentId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Equipment(EquipmentId),
    ParameterName NVARCHAR(150) NOT NULL,
    ParameterValue DECIMAL(14,4) NOT NULL,
    UnitOfMeasure NVARCHAR(30) NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

--Лаборатория, отклонения, аудит--

CREATE TABLE dbo.LabTests (
    LabTestId INT IDENTITY(1,1) PRIMARY KEY,
    ProductionBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionBatches(ProductionBatchId),
    TestName NVARCHAR(200) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'PLANNED'
        CHECK (Status IN (N'PLANNED', N'IN_PROGRESS', N'PASSED', N'FAILED')),
    PerformedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ResultValue DECIMAL(14,4) NULL,
    ResultUnit NVARCHAR(30) NULL,
    Decision NVARCHAR(20) NULL
        CHECK (Decision IN (N'PASS', N'FAIL', N'PENDING')),
    PerformedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Deviations (
    DeviationId INT IDENTITY(1,1) PRIMARY KEY,
    ProductionBatchId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.ProductionBatches(ProductionBatchId),
    ExecutionId INT NULL
        FOREIGN KEY REFERENCES dbo.BatchStepExecutions(ExecutionId),
    LabTestId INT NULL
        FOREIGN KEY REFERENCES dbo.LabTests(LabTestId),
    Severity NVARCHAR(20) NOT NULL
        CHECK (Severity IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
    Status NVARCHAR(20) NOT NULL DEFAULT N'OPEN'
        CHECK (Status IN (N'OPEN', N'IN_REVIEW', N'RESOLVED', N'CLOSED')),
    Description NVARCHAR(MAX) NOT NULL,
    DetectedBy INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ResolvedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ResolvedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Notifications (
    NotificationId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    IsRead BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.AuditEvents (
    AuditEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(100) NOT NULL,
    EntityId INT NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    UserId INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    EventAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.StatusHistory (
    HistoryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(100) NOT NULL,
    EntityId INT NOT NULL,
    OldStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    ChangedBy INT NULL
        FOREIGN KEY REFERENCES dbo.Users(UserId),
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

--Ограничения--

CREATE UNIQUE INDEX UX_Recipes_OneActive
ON dbo.Recipes (ProductId)
WHERE Status = N'APPROVED_ACTIVE';

CREATE UNIQUE INDEX UX_TechCards_OneActive
ON dbo.TechCards (ProductId)
WHERE Status = N'APPROVED_ACTIVE';

CREATE FUNCTION dbo.fn_RecipeComponentsTotal
(
    @RecipeId INT
)
RETURNS DECIMAL(10,4)
AS
BEGIN
    DECLARE @Total DECIMAL(10,4);

    SELECT @Total = ISNULL(SUM(Percentage), 0)
    FROM dbo.RecipeComponents
    WHERE RecipeId = @RecipeId;

    RETURN @Total;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Recipes_ApprovalCheck
ON dbo.Recipes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.RecipeId = i.RecipeId
        WHERE i.Status = N'APPROVED_ACTIVE'
          AND ISNULL(d.Status, N'') <> N'APPROVED_ACTIVE'
    )
        RETURN;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.Status = N'APPROVED_ACTIVE'
          AND dbo.fn_RecipeComponentsTotal(i.RecipeId) <> 100
    )
    BEGIN
        RAISERROR (
            N'Нельзя утвердить рецептуру: сумма долей компонентов должна быть равна 100%%.',
            16,
            1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

--Тестовые данные--

INSERT INTO dbo.Departments (Name) VALUES
(N'Технологический отдел'),
(N'Производственный цех'),
(N'Лаборатория'),
(N'IT / Администрирование');

INSERT INTO dbo.Users (FullName, Login, Email, Role, DepartmentId) VALUES
(N'Иванов Иван', N'i.ivanov', N'ivanov@company.ru', N'TECHNOLOGIST', 1),
(N'Петров Пётр', N'p.petrov', N'petrov@company.ru', N'OPERATOR', 2),
(N'Сидорова Анна', N'a.sidorova', N'sidorova@company.ru', N'LAB_WORKER', 3),
(N'Админ Алексей', N'admin', N'admin@company.ru', N'ADMIN', 4);

INSERT INTO dbo.Products (Name, ProductType, ReleaseForm, Status) VALUES
(N'Таблетки Парацетамол 500 мг', N'Лекарственный препарат', N'Таблетки', N'ACTIVE'),
(N'Сироп от кашля', N'Лекарственный препарат', N'Сироп', N'ACTIVE');

INSERT INTO dbo.Materials (Name, MaterialType, UnitOfMeasure) VALUES
(N'Парацетамол', N'АПИ', N'кг'),
(N'Крахмал', N'Вспомогательное вещество', N'кг'),
(N'Магния стеарат', N'Вспомогательное вещество', N'кг'),
(N'Вода очищенная', N'Растворитель', N'л');

INSERT INTO dbo.MaterialBatches
(MaterialId, BatchNumber, Quantity, ReceivedAt, ExpiryDate)
VALUES
(1, N'API-2026-001', 50, '2026-11-01', '2027-11-01'),
(2, N'STARCH-2026-001', 100, '2026-11-01', '2027-11-01'),
(3, N'MGST-2026-001', 10, '2026-11-01', '2027-11-01'),
(4, N'WATER-2026-001', 500, '2026-11-01', '2027-11-01');

INSERT INTO dbo.Equipment (Name, EquipmentType, Location) VALUES
(N'Смеситель SM-100', N'Смеситель', N'Цех 1'),
(N'Таблет-пресс TP-200', N'Пресс', N'Цех 1');

INSERT INTO dbo.Recipes (ProductId, Version, Name, Status, CreatedBy)
VALUES (1, 1, N'Рецептура парацетамола 500 мг v1', N'DRAFT', 1);

INSERT INTO dbo.RecipeComponents (RecipeId, MaterialId, Percentage) VALUES
(1, 1, 90.0000),
(1, 2, 8.0000),
(1, 3, 2.0000);

INSERT INTO dbo.TechCards (ProductId, Version, Name, Status, CreatedBy)
VALUES (1, 1, N'Техкарта таблетирования v1', N'DRAFT', 1);

INSERT INTO dbo.TechCardSteps (TechCardId, StepNumber, Name, Description, StandardDurationMinutes) VALUES
(1, 1, N'Смешивание', N'Смешать компоненты', 30),
(1, 2, N'Таблетирование', N'Прессование таблеток', 60),
(1, 3, N'Упаковка', N'Упаковать готовую продукцию', 20);

INSERT INTO dbo.StepParameters
(TechCardStepId, ParameterName, TargetValue, MinValue, MaxValue, UnitOfMeasure)
VALUES
(1, N'Температура смешивания', 25, 20, 30, N'C'),
(2, N'Давление прессования', 15, 10, 20, N'кН');

INSERT INTO dbo.ProductionOrders
(OrderNumber, ProductId, RecipeId, TechCardId, PlannedQuantity, Status, CreatedBy)
VALUES
(N'PO-2026-0001', 1, 1, 1, 1000, N'CREATED', 1);

INSERT INTO dbo.ProductionBatches
(BatchNumber, ProductionOrderId, ProductId, RecipeId, TechCardId, Status, StartedBy, StartedAt)
VALUES
(N'BATCH-2026-0001', 1, 1, 1, 1, N'IN_PROGRESS', 2, SYSUTCDATETIME());

INSERT INTO dbo.BatchMaterialUsage
(ProductionBatchId, MaterialBatchId, QuantityUsed, UsedBy)
VALUES
(1, 1, 4.5, 2),
(1, 2, 0.4, 2),
(1, 3, 0.1, 2);

INSERT INTO dbo.BatchStepExecutions
(ProductionBatchId, TechCardStepId, Status, StartedBy, StartedAt)
VALUES
(1, 1, N'COMPLETED', 2, DATEADD(HOUR, -2, SYSUTCDATETIME())),
(1, 2, N'IN_PROGRESS', 2, SYSUTCDATETIME());

INSERT INTO dbo.ExecutionParameterValues
(ExecutionId, ParameterId, MeasuredValue, RecordedBy)
VALUES
(1, 1, 24.5, 2);

INSERT INTO dbo.EquipmentTelemetry
(ProductionBatchId, EquipmentId, ParameterName, ParameterValue, UnitOfMeasure)
VALUES
(1, 1, N'Температура', 24.5, N'C');

INSERT INTO dbo.LabTests
(ProductionBatchId, TestName, Status, PerformedBy, ResultValue, ResultUnit, Decision, PerformedAt)
VALUES
(1, N'Определение содержания действующего вещества', N'PASSED', 3, 502.0, N'мг', N'PASS', SYSUTCDATETIME());

INSERT INTO dbo.Deviations
(ProductionBatchId, ExecutionId, Severity, Status, Description, DetectedBy)
VALUES
(1, 2, N'LOW', N'OPEN', N'Незначительное отклонение давления прессования', 2);

INSERT INTO dbo.Notifications (UserId, Title, Message) VALUES
(1, N'Отклонение в партии', N'В партии BATCH-2026-0001 зафиксировано отклонение давления прессования.');

--Тесты--

-- Должно пройти: сумма компонентов = 100--
UPDATE dbo.Recipes
SET Status = N'APPROVED_ACTIVE'
WHERE RecipeId = 1;

-- Должно пройти: одна активная техкарта--
UPDATE dbo.TechCards
SET Status = N'APPROVED_ACTIVE'
WHERE TechCardId = 1;

-- Нарушение: вторая активная рецептура--
INSERT INTO dbo.Recipes (ProductId, Version, Name, Status, CreatedBy)
VALUES (1, 2, N'Рецептура v2', N'APPROVED_ACTIVE', 1);