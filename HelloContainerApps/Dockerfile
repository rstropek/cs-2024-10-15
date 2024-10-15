FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /xy
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet build
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=base /xy/out .
ENTRYPOINT ["dotnet", "HelloContainerApps.dll"]
