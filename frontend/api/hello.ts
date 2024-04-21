export const config = {
  runtime: "nodejs",
}

export function GET(request: Request) {
  return new Response(`Hello ${Date.now()}`)
}
