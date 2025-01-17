package logger

import (
    "os"
    "path/filepath"
    "time"

    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

var (
    Log   *zap.Logger
    Sugar *zap.SugaredLogger
)

// InitLogger configures and initializes the logger.
func InitLogger() *zap.Logger {
    // Prepare log directory
    logDir := "logs"
    logFile := filepath.Join(logDir, "app.log")
    if err := os.MkdirAll(logDir, 0744); err != nil {
        panic("failed to create logs directory: " + err.Error())
    }

    // Open the file (create if it doesn't exist, append existing data, etc.)
    file, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        panic("failed to open log file: " + err.Error())
    }

    // Define the minimum logging level
    level := zap.NewAtomicLevelAt(zapcore.InfoLevel)

    // 1) Console encoder (colorful, developer-friendly)
    consoleEncoderConfig := zap.NewDevelopmentEncoderConfig()
    consoleEncoderConfig.TimeKey = "time"
    consoleEncoderConfig.EncodeTime = zapcore.TimeEncoderOfLayout("2006-01-02 15:04:05")
    consoleEncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
    consoleEncoderConfig.EncodeCaller = zapcore.ShortCallerEncoder
    consoleEncoder := zapcore.NewConsoleEncoder(consoleEncoderConfig)

    // 2) File encoder (plain or JSON, your choice)
    fileEncoderConfig := zap.NewProductionEncoderConfig()
    fileEncoderConfig.TimeKey = "timestamp"
    fileEncoderConfig.EncodeTime = func(t time.Time, enc zapcore.PrimitiveArrayEncoder) {
        enc.AppendString(t.Format("2006-01-02T15:04:05Z07:00"))
    }
    fileEncoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
    fileEncoderConfig.EncodeCaller = zapcore.ShortCallerEncoder
    fileEncoder := zapcore.NewConsoleEncoder(fileEncoderConfig)
    //  Or, for JSON: fileEncoder := zapcore.NewJSONEncoder(fileEncoderConfig)

    // 3) Create write syncers
    consoleSyncer := zapcore.AddSync(os.Stdout)
    fileSyncer := zapcore.AddSync(file) // wrap the file in a WriteSyncer

    // 4) Create cores
    consoleCore := zapcore.NewCore(consoleEncoder, consoleSyncer, level)
    fileCore := zapcore.NewCore(fileEncoder, fileSyncer, level)

    // 5) Tee them together
    core := zapcore.NewTee(consoleCore, fileCore)

    // 6) Build the final logger
    Log = zap.New(
        core,
        zap.AddCallerSkip(1),                  // Adjust call stack (skip wrapper)
        zap.AddStacktrace(zapcore.ErrorLevel), // Automatic stack trace on errors
        zap.Development(),                     // For dev-friendly mode
    )

    // Create a sugared logger as well
    Sugar = Log.Sugar()

    return Log
}

// Sugared Logger Methods
func Infof(template string, args ...interface{}) {
    Sugar.Infof(template, args...)
}

func Warnf(template string, args ...interface{}) {
    Sugar.Warnf(template, args...)
}

func Errorf(template string, args ...interface{}) {
    Sugar.Errorf(template, args...)
}

func Debugf(template string, args ...interface{}) {
    Sugar.Debugf(template, args...)
}

func Fatalf(template string, args ...interface{}) {
    Sugar.Fatalf(template, args...)
}

// WithFields adds structured fields to logs
func WithFields(fields map[string]interface{}) *zap.SugaredLogger {
    return Sugar.With(fields)
}

// Standard Logger Methods
func Info(msg string, fields ...zap.Field) {
    Log.Info(msg, fields...)
}

func Warn(msg string, fields ...zap.Field) {
    Log.Warn(msg, fields...)
}

func Error(msg string, fields ...zap.Field) {
    Log.Error(msg, fields...)
}

func Fatal(msg string, fields ...zap.Field) {
    Log.Fatal(msg, fields...)
}

// Cleanup
func Sync() {
    _ = Sugar.Sync()
    _ = Log.Sync()
}
