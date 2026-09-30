import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_get_stories_showcase(client: AsyncClient):
    """GET /api/v1/community/stories returns official PawConnect tips and active pet stories."""
    res = await client.get("/api/v1/community/stories")
    assert res.status_code == 200
    stories = res.json()
    assert isinstance(stories, list)
    assert len(stories) >= 2

    # Check official PawConnect story
    official_stories = [s for s in stories if s.get("is_official") is True or s.get("isOfficial") is True]
    assert len(official_stories) >= 1
    official = official_stories[0]
    assert "PawConnect" in official.get("author_name", "") or "PawConnect" in official.get("authorName", "")
    assert "media_url" in official or "mediaUrl" in official
    assert official.get("district") == "Центральный"
    assert official.get("status_text") or official.get("statusText")

    # Check active walking pets story
    pet_stories = [s for s in stories if s.get("pet_name") or s.get("petName")]
    assert len(pet_stories) >= 1
    assert pet_stories[0].get("district") is not None


@pytest.mark.asyncio
async def test_get_posts_includes_official_showcase(client: AsyncClient):
    """GET /api/v1/community/posts includes official PawConnect Team guide with verified status."""
    res = await client.get("/api/v1/community/posts")
    assert res.status_code == 200
    posts = res.json()
    assert isinstance(posts, list)
    assert len(posts) >= 1

    official_posts = [p for p in posts if p.get("is_official") is True or p.get("isOfficial") is True]
    assert len(official_posts) >= 1
    official = official_posts[0]
    assert "PawConnect" in (official.get("author_name") or official.get("authorName") or "")
    assert official.get("category") == "training"
    assert "безопасн" in (official.get("text") or official.get("content") or "").lower()


@pytest.mark.asyncio
async def test_filter_posts_by_district_and_category(client: AsyncClient):
    """Posts can be filtered by district and category."""
    # Filter by Central district
    res_central = await client.get("/api/v1/community/posts", params={"district": "Центральный"})
    assert res_central.status_code == 200
    for p in res_central.json():
        assert p.get("district") == "Центральный"

    # Filter by category training
    res_training = await client.get("/api/v1/community/posts", params={"category": "training"})
    assert res_training.status_code == 200
    for p in res_training.json():
        assert p.get("category") == "training"


@pytest.mark.asyncio
async def test_post_creation_and_like(client: AsyncClient):
    """User can create a post and like it."""
    # Register user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "author@pawconnect.app", "password": "pass", "name": "Алиса В."},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Create post
    create_res = await client.post(
        "/api/v1/community/posts",
        headers=headers,
        json={
            "district": "Советский (Академгородок)",
            "category": "health",
            "title": "Прогулка в лесу Академа",
            "text": "Отличная погода для прогулок с питомцами!",
            "photo_url": "https://example.com/forest.jpg",
            "pet_name": "Бим (Шелти)",
        },
    )
    assert create_res.status_code == 201
    post = create_res.json()
    post_id = post["id"]
    assert post["district"] == "Советский (Академгородок)"
    assert post["likes_count"] == 0

    # Like post
    like_res = await client.post(
        f"/api/v1/community/posts/{post_id}/like",
        headers=headers,
    )
    assert like_res.status_code == 200
    liked_post = like_res.json()
    assert liked_post["likes_count"] == 1


@pytest.mark.asyncio
async def test_post_comments_flow(client: AsyncClient):
    """User can add comments to a post and retrieve comments."""
    # 1. Register user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "commenter@pawconnect.app", "password": "pass", "name": "Иван С."},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Get posts to find a post id
    posts_res = await client.get("/api/v1/community/posts")
    assert posts_res.status_code == 200
    post_id = posts_res.json()[0]["id"]

    # 3. Add comment
    add_comment_res = await client.post(
        f"/api/v1/community/posts/{post_id}/comments",
        headers=headers,
        json={"text": "Отличная рекомендация! Обязательно применим."},
    )
    assert add_comment_res.status_code in (200, 201)
    comment = add_comment_res.json()
    assert comment["text"] == "Отличная рекомендация! Обязательно применим."
    assert comment.get("author_name") == "Иван С." or comment.get("authorName") == "Иван С."

    # 4. Get comments for post
    get_comments_res = await client.get(f"/api/v1/community/posts/{post_id}/comments")
    assert get_comments_res.status_code == 200
    comments = get_comments_res.json()
    assert isinstance(comments, list)
    assert any(c["text"] == "Отличная рекомендация! Обязательно применим." for c in comments)


@pytest.mark.asyncio
async def test_comments_nonexistent_post_returns_404(client: AsyncClient):
    """Adding or getting comments for non-existent post returns 404."""
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "tester@pawconnect.app", "password": "pass", "name": "Тестер"},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    fake_id = "ffffffff-ffff-ffff-ffff-ffffffffffff"
    res = await client.get(f"/api/v1/community/posts/{fake_id}/comments")
    assert res.status_code == 404

    post_res = await client.post(
        f"/api/v1/community/posts/{fake_id}/comments",
        headers=headers,
        json={"text": "Hello"},
    )
    assert post_res.status_code == 404
