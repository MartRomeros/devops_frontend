const runtimeConfig = window.__APP_CONFIG__ || {};

const defaultConfig = {
  ventasApiUrl: import.meta.env.VITE_VENTAS_API_URL || "http://localhost:8082/api/v1",
  despachosApiUrl:
    import.meta.env.VITE_DESPACHOS_API_URL || "http://localhost:8081/api/v1",
};

export const appConfig = {
  ventasApiUrl: runtimeConfig.APP_VENTAS_API_URL || defaultConfig.ventasApiUrl,
  despachosApiUrl:
    runtimeConfig.APP_DESPACHOS_API_URL || defaultConfig.despachosApiUrl,
};

export const buildApiUrl = (baseUrl, resourcePath) => {
  const normalizedBaseUrl = baseUrl.replace(/\/+$/, "");
  const normalizedResourcePath = resourcePath.replace(/^\/+/, "");

  return `${normalizedBaseUrl}/${normalizedResourcePath}`;
};
