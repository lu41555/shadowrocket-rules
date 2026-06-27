/*
 * YouTube AdBlock MITM Experimental
 * Works with Shadowrocket/Surge-style response scripting.
 * The script is intentionally conservative: it removes known ad containers
 * and promoted renderers without touching normal video renderers.
 */

const body = typeof $response !== "undefined" ? $response.body : "";

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

const blockedKeys = new Set([
  "adPlacements",
  "adSlots",
  "playerAds",
  "adBreakHeartbeatParams",
  "adParams",
  "adSafetyReason",
  "adSignalsInfo",
  "adSlotRenderer",
  "displayAdRenderer",
  "promotedVideoRenderer",
  "compactPromotedVideoRenderer",
  "promotedSparklesWebRenderer",
  "promotedSparklesTextSearchRenderer",
  "carouselAdRenderer",
  "searchPyvRenderer",
  "pyvWatchRelatedItemRenderer",
  "inFeedAdLayoutRenderer",
  "bannerPromoRenderer",
  "mealbarPromoRenderer",
  "primetimePromoRenderer",
  "merchandiseShelfRenderer",
  "statementBannerRenderer",
  "playerLegacyDesktopYpcTrailerRenderer",
  "ypcTrailerRenderer"
]);

const blockedRendererKeys = [
  "adSlotRenderer",
  "displayAdRenderer",
  "promotedVideoRenderer",
  "compactPromotedVideoRenderer",
  "promotedSparklesWebRenderer",
  "promotedSparklesTextSearchRenderer",
  "carouselAdRenderer",
  "searchPyvRenderer",
  "pyvWatchRelatedItemRenderer",
  "inFeedAdLayoutRenderer",
  "mealbarPromoRenderer"
];

function looksLikeAdContainer(value) {
  if (!isObject(value)) return false;

  for (const key of blockedRendererKeys) {
    if (Object.prototype.hasOwnProperty.call(value, key)) return true;
  }

  const text = JSON.stringify(value).slice(0, 3000).toLowerCase();
  return (
    text.includes("sponsored") ||
    text.includes("promoted") ||
    text.includes("statement_banner") ||
    text.includes("googleads") ||
    text.includes("doubleclick")
  );
}

function clean(value) {
  if (Array.isArray(value)) {
    const result = [];
    for (const item of value) {
      if (looksLikeAdContainer(item)) continue;
      const cleaned = clean(item);
      if (cleaned !== undefined) result.push(cleaned);
    }
    return result;
  }

  if (!isObject(value)) return value;

  for (const key of Object.keys(value)) {
    if (blockedKeys.has(key)) {
      delete value[key];
      continue;
    }

    const child = value[key];
    if (looksLikeAdContainer(child)) {
      delete value[key];
      continue;
    }

    value[key] = clean(child);
  }

  return value;
}

function tunePlayerResponse(json) {
  if (json && json.playbackTracking) {
    delete json.playbackTracking.adTrackingUrl;
    delete json.playbackTracking.qoeUrl;
    delete json.playbackTracking.ptrackingUrl;
  }

  if (json && json.playerConfig && json.playerConfig.mediaCommonConfig) {
    delete json.playerConfig.mediaCommonConfig.dynamicReadaheadConfig;
  }

  if (json && json.responseContext) {
    delete json.responseContext.serviceTrackingParams;
    delete json.responseContext.mainAppWebResponseContext;
    delete json.responseContext.webResponseContextExtensionData;
  }

  return json;
}

try {
  const json = JSON.parse(body);
  const cleaned = tunePlayerResponse(clean(json));
  $done({ body: JSON.stringify(cleaned) });
} catch (error) {
  $done({ body });
}
