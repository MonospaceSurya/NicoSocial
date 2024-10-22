from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional, Dict, Any
import google.generativeai as genai
import json
import os
from datetime import datetime

# Models
class UserProfile(BaseModel):
    user_id: str
    name: str
    age: int
    location: str
    cuisine_preferences: List[str] = Field(default_factory=list)
    interests: List[str] = Field(default_factory=list)
    social_style: str
    available_times: List[str] = Field(default_factory=list)
    personality_traits: List[str] = Field(default_factory=list)
    goals: List[str] = Field(default_factory=list)
    
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "user_id": "user123",
                "name": "John Doe",
                "age": 28,
                "location": "New York City",
                "cuisine_preferences": ["Italian", "Japanese"],
                "interests": ["Photography", "Cooking"],
                "social_style": "Ambivert",
                "available_times": ["Weekend Afternoons"],
                "personality_traits": ["Creative", "Social"],
                "goals": ["Learn new skills", "Meet new people"]
            }
        }
    )

class EventTime(BaseModel):
    day: str
    start_time: str
    end_time: str

class Event(BaseModel):
    event_id: str
    name: str
    type: str
    cuisine: Optional[str] = None
    time: EventTime
    location: str
    social_level: str
    description: str
    tags: List[str]
    skill_level: str
    pacing: str
    interaction_level: str
    environment_type: str
    host_id: str
    participants: List[str] = Field(default_factory=list)

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "event_id": "event001",
                "name": "Sunset Photography Workshop",
                "type": "Photography",
                "cuisine": None,
                "time": {
                    "day": "Saturday",
                    "start_time": "17:00",
                    "end_time": "20:00"
                },
                "location": "Central Park, New York City",
                "social_level": "Small group (5-10 people)",
                "description": "Capture the golden hour with expert guidance.",
                "tags": ["creative", "outdoors", "photography"],
                "skill_level": "beginner-friendly",
                "pacing": "relaxed",
                "interaction_level": "moderate",
                "environment_type": "outdoor",
                "host_id": "host123",
                "participants": ["user456", "user789"]
            }
        }
    )

class MatchScore(BaseModel):
    event_id: str
    match_score: float
    explanation: str
    matching_factors: List[str]

class EventMatchResponse(BaseModel):
    matches: List[MatchScore]

# Initialize FastAPI app
app = FastAPI(
    title="Event Matching API",
    description="API for matching users with social events based on profiles and preferences",
    version="1.0.0"
)

# Initialize Gemini AI
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-pro')
else:
    print("Warning: GEMINI_API_KEY not set. AI matching will fall back to basic matching.")

async def generate_match_prompt(user_profile: UserProfile, event: Event) -> str:
    return f"""
    You are an AI event matching expert. Analyze the following user profile and event to determine compatibility.
    Consider these factors:
    1. Interest alignment
    2. Social style compatibility
    3. Schedule compatibility
    4. Personal goals alignment
    5. Activity type preferences
    6. Environmental preferences
    
    User Profile:
    {json.dumps(user_profile.model_dump(), indent=2)}

    Event:
    {json.dumps(event.model_dump(), indent=2)}

    Provide:
    1. A match score (0-100)
    2. A detailed explanation of why this event matches or doesn't match
    3. Key matching factors
    
    Format the response as a JSON object with this structure:
    {{
        "match_score": number,
        "explanation": "string",
        "matching_factors": ["string"]
    }}

    Focus on providing specific, personalized reasoning for the match.
    """

async def calculate_match_score(user_profile: UserProfile, event: Event) -> MatchScore:
    try:
        if GEMINI_API_KEY:
            prompt = await generate_match_prompt(user_profile, event)
            response = model.generate_content(prompt)
            result = json.loads(response.text)
            
            return MatchScore(
                event_id=event.event_id,
                match_score=result["match_score"],
                explanation=result["explanation"],
                matching_factors=result["matching_factors"]
            )
    except Exception as e:
        print(f"AI matching failed, falling back to basic matching: {str(e)}")
    
    return calculate_basic_match_score(user_profile, event)

def calculate_basic_match_score(user_profile: UserProfile, event: Event) -> MatchScore:
    score = 50  # Base score
    matching_factors = []
    
    # Interest matching
    matching_interests = set(user_profile.interests).intersection(set(event.tags))
    interest_score = len(matching_interests) * 10
    score += min(interest_score, 30)
    if matching_interests:
        matching_factors.append("interest_match")
    
    # Cuisine preferences
    if event.cuisine and event.cuisine in user_profile.cuisine_preferences:
        score += 10
        matching_factors.append("cuisine_match")
    
    # Social style matching
    social_style_score = {
        ("Introvert", "Small group"): 10,
        ("Extrovert", "Large group"): 10,
        ("Ambivert", "Medium group"): 10
    }.get((user_profile.social_style, event.social_level), 0)
    score += social_style_score
    if social_style_score > 0:
        matching_factors.append("social_style_match")
    
    return MatchScore(
        event_id=event.event_id,
        match_score=min(100, max(0, score)),
        explanation=f"Basic match score based on {len(matching_factors)} factors",
        matching_factors=matching_factors
    )

# API Endpoints

# 1. Create User Profile
@app.post("/api/v1/users/", response_model=UserProfile, summary="Create a new user profile")
async def create_user_profile(profile: UserProfile):
    """
    Creates a new user profile in the system.

    **Input:** UserProfile object (JSON)
    **Sample Input:**
        ```json
        {
            "user_id": "user123",
            "name": "John Doe",
            "age": 28,
            "location": "New York City",
            "cuisine_preferences": ["Italian", "Japanese"],
            "interests": ["Photography", "Cooking"],
            "social_style": "Ambivert",
            "available_times": ["Weekend Afternoons"],
            "personality_traits": ["Creative", "Social"],
            "goals": ["Learn new skills", "Meet new people"]
        }
        ```

    **Output:** Created UserProfile object (JSON)
    """
    # In a real application, you would save this to a database
    return profile

# 2. Get User Profile
@app.get("/api/v1/users/{user_id}", response_model=UserProfile, summary="Get a user profile by ID")
async def get_user_profile(user_id: str):
    """
    Retrieves a user profile by their unique ID.

    **Input:** User ID (string, path parameter)
    **Sample Input:** /api/v1/users/user123

    **Output:** UserProfile object (JSON)
    """
    # In a real application, you would fetch this from a database
    raise HTTPException(status_code=404, detail="User not found")

# 3. Create Event
@app.post("/api/v1/events/", response_model=Event, summary="Create a new event")
async def create_event(event: Event):
    """
    Creates a new event listing in the system.

    **Input:** Event object (JSON)
    **Sample Input:**
        ```json
        {
            "event_id": "event001",
            "name": "Sunset Photography Workshop",
            "type": "Photography",
            "cuisine": null, 
            "time": {
                "day": "Saturday",
                "start_time": "17:00",
                "end_time": "20:00"
            },
            "location": "Central Park, New York City",
            "social_level": "Small group (5-10 people)",
            "description": "Capture the golden hour with expert guidance.",
            "tags": ["creative", "outdoors", "photography"],
            "skill_level": "beginner-friendly",
            "pacing": "relaxed",
            "interaction_level": "moderate",
            "environment_type": "outdoor",
            "host_id": "host123",
            "participants": ["user456", "user789"] 
        }
        ```

    **Output:** Created Event object (JSON)
    """
    # In a real application, you would save this to a database
    return event

# 4. Get Event 
@app.get("/api/v1/events/{event_id}", response_model=Event, summary="Get an event by ID")
async def get_event(event_id: str):
    """
    Retrieves an event by its unique ID.

    **Input:** Event ID (string, path parameter)
    **Sample Input:** /api/v1/events/event001

    **Output:** Event object (JSON)
    """
    # In a real application, you would fetch this from a database
    raise HTTPException(status_code=404, detail="Event not found")

# 5. Get Event Matches for User
@app.post(
    "/api/v1/matches/user/{user_id}/events", 
    response_model=EventMatchResponse, 
    summary="Get event matches for a user"
)
async def get_event_matches(
    user_id: str,
    user_profile: UserProfile,
    events: List[Event]
) -> EventMatchResponse:
    """
    Generates a list of events matched to a user's profile, sorted by match score. 

    **Input:**
        - User ID (string, path parameter)
        - User Profile (UserProfile object, JSON body)
        - List of Events (List of Event objects, JSON body)

    **Sample Input:**
    ```
    /api/v1/matches/user/user123 
    ```
    ```json
    {
       "user_profile": { 
          // ... User Profile data ...
       },
       "events": [
          { 
              // ... Event 1 data ... 
          },
          {
              // ... Event 2 data ... 
          } 
       ] 
    } 
    ```

    **Output:** EventMatchResponse (JSON), containing a list of MatchScore objects. 
    """
    match_scores = []
    for event in events:
        score = await calculate_match_score(user_profile, event)
        match_scores.append(score)
    
    # Sort by match score descending
    match_scores.sort(key=lambda x: x.match_score, reverse=True)
    
    return EventMatchResponse(matches=match_scores)

# 6. Join Event
@app.post("/api/v1/events/{event_id}/join", summary="Join an event")
async def join_event(event_id: str, user_id: str):
    """
    Adds a user to the participant list of an event. 

    **Input:** 
       - Event ID (string, path parameter)
       - User ID (string, query parameter)
    
    **Sample Input:** /api/v1/events/event001/join?user_id=user123

    **Output:** Success message (JSON)
    """
    # In a real application, you would update the event participants in the database
    return {"message": f"User {user_id} joined event {event_id}"}

# 7. Leave Event
@app.post("/api/v1/events/{event_id}/leave", summary="Leave an event")
async def leave_event(event_id: str, user_id: str):
    """
    Removes a user from the participant list of an event.

    **Input:**
       - Event ID (string, path parameter)
       - User ID (string, query parameter)

    **Sample Input:** /api/v1/events/event001/leave?user_id=user123 

    **Output:** Success message (JSON)
    """
    # In a real application, you would update the event participants in the database
    return {"message": f"User {user_id} left event {event_id}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)