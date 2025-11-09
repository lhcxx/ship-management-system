FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project files
COPY ["src/ShipManagement.API/ShipManagement.API.csproj", "src/ShipManagement.API/"]
COPY ["src/ShipManagement.Core/ShipManagement.Core.csproj", "src/ShipManagement.Core/"]
COPY ["src/ShipManagement.Infrastructure/ShipManagement.Infrastructure.csproj", "src/ShipManagement.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "src/ShipManagement.API/ShipManagement.API.csproj"

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/src/ShipManagement.API"
RUN dotnet build "ShipManagement.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "ShipManagement.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ShipManagement.API.dll"]
