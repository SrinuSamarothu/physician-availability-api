#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["AvailabilityApiService/AvailabilityApiService.csproj", "AvailabilityApiService/"]
COPY ["AvailabilityBusinessLogic/AvailabilityBusinessLogic.csproj", "AvailabilityBusinessLogic/"]
COPY ["FluentApi/FluentApi.csproj", "FluentApi/"]
COPY ["AvailabilityModels/AvailabilityModels.csproj", "AvailabilityModels/"]
RUN dotnet restore "AvailabilityApiService/AvailabilityApiService.csproj"
COPY . .
WORKDIR "/src/AvailabilityApiService"
RUN dotnet build "AvailabilityApiService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AvailabilityApiService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AvailabilityApiService.dll"]