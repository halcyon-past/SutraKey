import { NextResponse } from "next/server";
import { pingIndexNow, URL_LIST } from "../../../scripts/ping-indexnow.mjs";

export async function GET(request: Request) {
  try {
    const results = await pingIndexNow();
    return NextResponse.json({
      success: true,
      message: "IndexNow submission triggered successfully",
      submittedUrls: URL_LIST,
      results,
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Failed to trigger IndexNow",
      },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  return GET(request);
}
