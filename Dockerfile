# Stage 1: Build (instala .NET en Ubuntu 22.04 para evitar pull errors)
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y dotnet-sdk-8.0 ca-certificates && rm -rf /var/lib/apt/lists/*

# Set the working directory for the build stage
WORKDIR /source

# Copy the project file
COPY ["OverDMA-LicenseServer.csproj", "./"]

# Restore dependencies
RUN dotnet restore "OverDMA-LicenseServer.csproj"

# Copy the rest of the source files
COPY . .

# Build and publish your application
WORKDIR /source
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "OverDMA-LicenseServer.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 2: Run (usa runtime oficial, pero simple)
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=builder /app/publish .
ENTRYPOINT ["dotnet", "OverDMA-LicenseServer.dll"]