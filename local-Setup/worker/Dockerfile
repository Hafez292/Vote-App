FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2
FROM mcr.microsoft.com/dotnet/runtime:7.0-alpine
WORKDIR /app

# Create a non-root user and group
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# Copy published app from build stage
COPY --from=build /app/publish .

# Run the worker
ENTRYPOINT ["dotnet", "Worker.dll"]