FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    gnupg \
    ca-certificates

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

RUN apt-get update
RUN apt-get install -y dotnet-sdk-8.0

WORKDIR /src
COPY ["OverDMA-LicenseServer.csproj", "./"]
RUN dotnet restore "OverDMA-LicenseServer.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "OverDMA-LicenseServer.csproj" -c Release -o /app/build

FROM builder AS publish
RUN dotnet publish "OverDMA-LicenseServer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    gnupg \
    ca-certificates

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

RUN apt-get update
RUN apt-get install -y aspnetcore-runtime-8.0  # Cambiado de dotnet-runtime-8.0 a aspnetcore-runtime-8.0

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OverDMA-LicenseServer.dll"]