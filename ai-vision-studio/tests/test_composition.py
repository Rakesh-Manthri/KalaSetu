import numpy as np
import pytest
import cv2

from vision_studio.pipeline.composition import compose, compose_product, hex_to_bgr, CompositionResult
from vision_studio.contracts import EnhanceOptions


class TestHexToBgr:
    """Test hex string parsing to BGR format."""

    def test_standard_6_char_hex(self):
        assert hex_to_bgr("#FFFFFF") == (255, 255, 255)
        assert hex_to_bgr("#000000") == (0, 0, 0)
        assert hex_to_bgr("#FF0000") == (0, 0, 255)  # Red -> BGR (0, 0, 255)
        assert hex_to_bgr("#00FF00") == (0, 255, 0)  # Green -> BGR (0, 255, 0)
        assert hex_to_bgr("#0000FF") == (255, 0, 0)  # Blue -> BGR (255, 0, 0)

    def test_3_char_shorthand_hex(self):
        assert hex_to_bgr("#FFF") == (255, 255, 255)
        assert hex_to_bgr("#000") == (0, 0, 0)
        assert hex_to_bgr("#F00") == (0, 0, 255)

    def test_invalid_hex_falls_back_to_white(self):
        assert hex_to_bgr("invalid") == (255, 255, 255)
        assert hex_to_bgr(None) == (255, 255, 255)
        assert hex_to_bgr("") == (255, 255, 255)


class TestComposition:
    """Test product foreground composition on e-commerce canvas."""

    @pytest.fixture
    def synthetic_foreground_and_mask(self):
        """Create a synthetic 400x300 foreground with a 200x150 subject."""
        h, w = 300, 400
        fg = np.zeros((h, w, 3), dtype=np.uint8)
        mask = np.zeros((h, w), dtype=np.uint8)

        # Subject rect: x=100, y=50, w=200, h=150
        fg[50:200, 100:300] = [50, 120, 200]  # Orange-ish in BGR
        mask[50:200, 100:300] = 255
        bbox = (100, 50, 200, 150)

        return fg, mask, bbox

    def test_default_canvas_dimensions_and_type(self, synthetic_foreground_and_mask):
        fg, mask, bbox = synthetic_foreground_and_mask
        result = compose(fg, mask, bbox)

        assert isinstance(result, CompositionResult)
        assert isinstance(result.image, np.ndarray)
        assert result.image.dtype == np.uint8
        assert result.image.shape == (1000, 1000, 3)

    def test_custom_canvas_size(self, synthetic_foreground_and_mask):
        fg, mask, bbox = synthetic_foreground_and_mask
        options = EnhanceOptions(output_size=(800, 800))
        result = compose(fg, mask, bbox, cfg=options)

        assert result.image.shape == (800, 800, 3)
        assert result.metadata["output_size"] == [800, 800]

    def test_background_color_rendered(self, synthetic_foreground_and_mask):
        fg, mask, bbox = synthetic_foreground_and_mask
        # Pure red background: #FF0000 -> BGR (0, 0, 255)
        options = EnhanceOptions(background_color="#FF0000", quality="fast")
        result = compose(fg, mask, bbox, cfg=options)

        # Top-left corner must strictly match the background color
        top_left_pixel = result.image[0, 0]
        assert tuple(top_left_pixel) == (0, 0, 255)

    def test_subject_centering_and_margin(self, synthetic_foreground_and_mask):
        fg, mask, bbox = synthetic_foreground_and_mask
        # Canvas: 1000x1000. 8% margin = 80px on all sides. Max subject box = 840x840.
        # Subject is 200w x 150h (aspect ratio 4:3).
        # Scale: min(840/200, 840/150) = min(4.2, 5.6) = 4.2 -> new_w = 840, new_h = 630.
        # Centering offsets: offset_x = (1000 - 840)//2 = 80, offset_y = (1000 - 630)//2 = 185.
        options = EnhanceOptions(quality="fast")
        result = compose(fg, mask, bbox, cfg=options)

        assert result.metadata["margin_pct"] == 0.08
        new_w, new_h = result.metadata["subject_dims"]
        assert new_w == 840
        assert new_h == 630
        assert result.metadata["offsets"] == [80, 185]

        # Check that canvas center contains subject color [50, 120, 200]
        center_pixel = result.image[500, 500]
        assert np.allclose(center_pixel, [50, 120, 200], atol=2)

    def test_shadow_applied_in_balanced_and_skipped_in_fast(self, synthetic_foreground_and_mask):
        fg, mask, bbox = synthetic_foreground_and_mask

        res_fast = compose(fg, mask, bbox, cfg=EnhanceOptions(quality="fast"))
        assert res_fast.metadata["shadow_applied"] is False

        res_balanced = compose(fg, mask, bbox, cfg=EnhanceOptions(quality="balanced"))
        assert res_balanced.metadata["shadow_applied"] is True

        res_high = compose(fg, mask, bbox, cfg=EnhanceOptions(quality="high"))
        assert res_high.metadata["shadow_applied"] is True

    def test_none_bbox_and_empty_mask_fallback(self):
        h, w = 200, 200
        fg = np.full((h, w, 3), 120, dtype=np.uint8)
        mask = np.zeros((h, w), dtype=np.uint8)

        # Fallback when mask is empty and bbox is None
        result = compose(fg, mask, bbox=None)
        assert result.image.shape == (1000, 1000, 3)
        assert result.metadata["duration_ms"] >= 0

    def test_compatibility_wrapper(self, synthetic_foreground_and_mask):
        fg, _, _ = synthetic_foreground_and_mask
        out_img, meta = compose_product(fg)
        assert isinstance(out_img, np.ndarray)
        assert isinstance(meta, dict)
