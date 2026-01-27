vim9script

# Build OpenAI API request payload
def BuildPayload(text: string, ratio: float): dict<any>
  const target = float2nr(ratio * 100)
  const prompt = $"Rewrite the provided text so it is roughly {target}% of the original length (25-30% shorter).\n"
    .. "Keep the tone neutral and ensure the meaning stays intact.\n"
    .. "Return only the revised text without commentary or code fences."

  return {
    model: g:->get('clearcut_model', 'gpt-4o-mini'),
    messages: [
      {
        role: 'system',
        content: 'You are a concise editor that trims redundant words without losing nuance.'
      },
      {
        role: 'user',
        content: $"{prompt}\n\n---\n{text}\n---"
      }
    ],
    temperature: 0.2
  }
enddef

# Call OpenAI API using curl
def CallOpenAI(text: string, ratio: float): string
  const api_key = $OPEN_AI_KEY
  if empty(api_key)
    throw 'OPEN_AI_KEY environment variable is not set'
  endif

  const endpoint = g:->get('clearcut_endpoint', 'https://api.openai.com/v1/chat/completions')
  const payload = BuildPayload(text, ratio)
  const json_payload = json_encode(payload)

  # Build curl command
  const curl_cmd = 'curl -s -X POST '
    .. shellescape(endpoint)
    .. ' -H ' .. shellescape('Content-Type: application/json')
    .. ' -H ' .. shellescape($'Authorization: Bearer {api_key}')
    .. ' -d ' .. shellescape(json_payload)

  const response = system(curl_cmd)

  if v:shell_error != 0
    throw $'curl failed with exit code {v:shell_error}: {response}'
  endif

  # Parse JSON response
  var response_data: dict<any>
  try
    response_data = json_decode(response)
  catch
    throw $'Failed to parse API response: {response}'
  endtry

  # Extract message content
  if !has_key(response_data, 'choices')
      || empty(response_data.choices)
      || !has_key(response_data.choices[0], 'message')
      || !has_key(response_data.choices[0].message, 'content')
    # Check for API error
    if has_key(response_data, 'error')
      const error = response_data.error
      const error_msg = has_key(error, 'message') ? error.message : string(error)
      throw $'OpenAI API error: {error_msg}'
    endif
    throw $'Unexpected API response format: {response}'
  endif

  return trim(response_data.choices[0].message.content)
enddef

# Main function called by :Clearcut command
export def Rewrite(line1: number, line2: number)
  # Get selected text
  const selected: list<string> = getline(line1, line2)
  const text: string = join(selected, "\n")

  if trim(text) == ''
    echoerr 'No text selected'
    return
  endif

  # Get configuration
  const ratio = g:->get('clearcut_target_ratio', 0.75)

  # Show progress message
  echom 'Calling OpenAI API...'

  # Call API
  var result: string
  try
    result = CallOpenAI(text, ratio)
  catch /^OPEN_AI_KEY/
    echoerr 'OPEN_AI_KEY environment variable is not set'
    return
  catch
    echoerr $'Clearcut rewrite failed: {v:exception}'
    return
  endtry

  # Insert result below selection
  const lines = split(result, "\n", true)
  append(line2, lines)

  echom $'Clearcut rewrite inserted ({len(lines)} lines)'
enddef
